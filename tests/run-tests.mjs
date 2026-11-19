// Repo tests. Run: node tests/run-tests.mjs (from repo root)
import { readFileSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

let failures = 0;
const check = (name, ok) => {
  console.log(`${ok ? 'PASS' : 'FAIL'} ${name}`);
  if (!ok) failures++;
};

// 1. Toolkit scripts exist and are executable
for (const t of ['tools/preflight.sh', 'tools/extract_reference.sh',
                 'tools/audio_events.py', 'tools/qa_sheets.sh', 'tools/encode.sh',
                 'tools/motion_measure.py', 'tools/side_by_side.sh']) {
  check(`${t} exists`, existsSync(t));
}

// 2. All ten skills present with frontmatter
const skills = ['reference-deconstruction', 'colour-theory', 'kinetic-typography',
  'captions', 'motion-graphics', 'audio-sync', 'edit-planning',
  'asset-sourcing', 'deterministic-render', 'qa-and-delivery'];
for (const s of skills) {
  const p = `skills/${s}/SKILL.md`;
  check(`skill ${s} exists with frontmatter`,
    existsSync(p) && readFileSync(p, 'utf8').startsWith('---'));
}

// 3. Demo beat sheet obeys the measured timing rules
const html = readFileSync('examples/kinetic-demo/composition.html', 'utf8');
const beats = [...html.matchAll(/\[\s*(\d+),\s*'([^']+)'/g)]
  .map(m => ({ start: +m[1], word: m[2] })).sort((a, b) => a.start - b.start);
check('demo has 8 beats', beats.length === 8);
for (let i = 1; i < beats.length; i++) {
  const gap = beats[i].start - beats[i - 1].start;
  if (beats[i].start < 90) // within scene A
    check(`word gap >= 12f before "${beats[i].word}"`, gap >= 12);
}
const flash = html.match(/FLASH_AT = (\d+), FLASH_LEN = (\d+)/);
check('flash is 2-4 frames (metros study)', +flash[2] >= 2 && +flash[2] <= 4);
const cardAt = +html.match(/CARD_AT\s*=\s*(\d+)/)[1];
check('end card holds >= 60f of 240', 240 - cardAt >= 60);
check('no wall-clock reads in composition',
  !/Date\.now|performance\.now|requestAnimationFrame/.test(html));

// 4. python tools compile
for (const p of ['tools/audio_events.py', 'tools/motion_measure.py',
                 'examples/promo-demo/make_audio.py']) {
  try {
    execFileSync('python3', ['-m', 'py_compile', p]);
    check(`${p} compiles`, true);
  } catch { check(`${p} compiles`, false); }
}

// 4b. promo-demo beat sheet obeys the same measured rules
const promo = readFileSync('examples/promo-demo/composition.html', 'utf8');
const pFlash = promo.match(/FLASH_AT = (\d+), FLASH_LEN = (\d+)/);
check('promo flash is 2-4 frames', +pFlash[2] >= 2 && +pFlash[2] <= 4);
const endAt = +promo.match(/END_AT = (\d+)/)[1];
check('promo end card holds >= 60f of 390', 390 - endAt >= 60);
check('promo has no wall-clock reads',
  !/Date\.now|performance\.now|requestAnimationFrame/.test(promo));
check('promo cascade stagger is 3 frames', /\[160,/.test(promo) && /\[163,/.test(promo) && /\[166,/.test(promo));

// 5. No reference footage committed anywhere in the tree
// mixed_audio.wav is a regenerable synthesized artifact (gitignored), not
// committed content - exclude it from the no-binaries check.
const banned = execFileSync('bash', ['-c',
  "find . -type d \\( -name node_modules -o -name out \\) -prune -o -type f " +
  "\\( -iname '*.mp4' -o -iname '*.mov' -o -iname '*.wav' -o -iname '*.mp3' \\) -print | grep -v '^$' | grep -v 'promo-demo/assets/mixed_audio.wav' || true"
]).toString().trim();
check('no video/audio binaries committed', banned === '');

process.exit(failures ? 1 : 0);
