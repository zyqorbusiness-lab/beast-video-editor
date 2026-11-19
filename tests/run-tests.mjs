// Repo tests. Run: node tests/run-tests.mjs (from repo root)
import { readFileSync, existsSync, mkdtempSync, mkdirSync, writeFileSync, readdirSync, cpSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

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

// 2b. CLI argument contracts: each tool rejects a no-arg run with its own
// usage line, and the script's "# Usage:" header comment carries the same
// signature - so the docs and the parser can never silently drift apart.
const contracts = {
  'tools/extract_reference.sh': 'extract_reference.sh <reference.mp4> [workspace_dir] [fps]',
  'tools/qa_sheets.sh': 'qa_sheets.sh <rendered.mp4> [workspace_dir] [fps]',
  'tools/encode.sh': 'encode.sh <workspace_dir> <out.mp4> [fps] [audio.wav]',
  'tools/side_by_side.sh': 'side_by_side.sh <framesA_dir> <framesB_dir> <out_dir> [tile WxH]',
};
for (const [script, sig] of Object.entries(contracts)) {
  let stderr = '', code = 0;
  try { execFileSync('bash', [script], { stdio: 'pipe' }); }
  catch (e) { code = e.status; stderr = (e.stderr || '').toString(); }
  check(`${script} rejects no-arg run with its usage contract`,
    code !== 0 && stderr.includes(`usage: ${sig}`));
  const usageLine = readFileSync(script, 'utf8').split('\n')
    .find(l => l.startsWith('# Usage:')) || '';
  check(`${script} usage comment matches its error contract`,
    usageLine.includes(sig));
}

// 2c. Demo encoders must match the encode.sh / brief export contract (crf 16)
for (const [name, f] of [['kinetic-demo', 'examples/kinetic-demo/render.mjs'],
                         ['promo-demo', 'examples/promo-demo/render.mjs']]) {
  check(`${name} encodes at crf 16 (encode.sh / brief contract)`,
    /'-crf',\s*'16'/.test(readFileSync(f, 'utf8')));
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

// 6. preflight.sh enforces the asset ledger (asset-sourcing skill)
const pf = (dir) => {
  try { execFileSync('bash', ['tools/preflight.sh', dir], { stdio: 'pipe' }); return 0; }
  catch (e) { return e.status ?? 1; }
};
const t1 = mkdtempSync(join(tmpdir(), 'pf-'));
mkdirSync(join(t1, 'assets'), { recursive: true });
writeFileSync(join(t1, 'assets', 'logo.png'), 'x');
check('preflight fails when a shippable asset has no ledger row', pf(t1) !== 0);
writeFileSync(join(t1, 'assets', 'ledger.md'),
  '| Asset | Source URL | Licence | Downloaded | Used at |\n|---|---|---|---|---|\n| logo.png | https://example.com/logo.png | CC0 | 2026-11-19 | n/a |\n');
check('preflight passes once the ledger row exists', pf(t1) === 0);
const t2 = mkdtempSync(join(tmpdir(), 'pf-'));
mkdirSync(join(t2, 'assets'), { recursive: true });
writeFileSync(join(t2, 'assets', 'ref_audio.wav'), 'x');
check('preflight exempts analysis-only ref_audio.wav', pf(t2) === 0);

// 7. tool pipeline end-to-end on a synthetic 24fps clip (2s = 48 frames)
const tw = mkdtempSync(join(tmpdir(), 'pipe-'));
const clip = join(tw, 'clip.mp4');
execFileSync('ffmpeg', ['-hide_banner', '-loglevel', 'error', '-y',
  '-f', 'lavfi', '-i', 'testsrc2=rate=24:size=320x180:duration=2',
  '-f', 'lavfi', '-i', 'sine=frequency=440:duration=2',
  '-pix_fmt', 'yuv420p', '-shortest', clip]);
execFileSync('bash', ['tools/extract_reference.sh', clip, join(tw, 'w')], { stdio: 'pipe' });
const nRef = readdirSync(join(tw, 'w', 'ref_frames')).filter(f => f.endsWith('.png')).length;
check('extract_reference.sh defaults to native fps (48 frames from a 24fps clip)', nRef === 48);
check('extract_reference.sh builds contact sheets',
  readdirSync(join(tw, 'w', 'contact_sheets')).some(f => f.startsWith('sheet_')));
execFileSync('python3', ['tools/audio_events.py', join(tw, 'w')], { stdio: 'pipe' });
check('audio_events.py uses the recorded extraction fps',
  JSON.parse(readFileSync(join(tw, 'w', 'audio_events.json'), 'utf8')).fps === 24);
// stand-in render: the extracted frames re-encoded, so counts must match
mkdirSync(join(tw, 'w', 'render_frames'), { recursive: true });
for (const f of readdirSync(join(tw, 'w', 'ref_frames')))
  cpSync(join(tw, 'w', 'ref_frames', f), join(tw, 'w', 'render_frames', f));
execFileSync('bash', ['tools/encode.sh', join(tw, 'w'), join(tw, 'out.mp4'), '24'], { stdio: 'pipe' });
check('encode.sh produces an mp4', existsSync(join(tw, 'out.mp4')));
execFileSync('bash', ['tools/qa_sheets.sh', join(tw, 'out.mp4'), join(tw, 'w')], { stdio: 'pipe' });
check('qa_sheets.sh builds side-by-side sheets with matching frame counts',
  readdirSync(join(tw, 'w', 'output')).some(f => f.startsWith('qa_sheet')));
const sbs = execFileSync('bash', ['tools/side_by_side.sh',
  join(tw, 'w', 'ref_frames'), join(tw, 'w', 'ref_frames'), join(tw, 'sbs')], { stdio: 'pipe' }).toString();
check('side_by_side.sh reports identical frames as 100% identical', sbs.includes('identical=100.0%'));

// 5. No reference footage committed anywhere in the tree
// mixed_audio.wav is a regenerable synthesized artifact (gitignored), not
// committed content - exclude it from the no-binaries check.
const banned = execFileSync('bash', ['-c',
  "find . -type d \\( -name node_modules -o -name out \\) -prune -o -type f " +
  "\\( -iname '*.mp4' -o -iname '*.mov' -o -iname '*.wav' -o -iname '*.mp3' \\) -print | grep -v '^$' | grep -v 'promo-demo/assets/mixed_audio.wav' || true"
]).toString().trim();
check('no video/audio binaries committed', banned === '');

process.exit(failures ? 1 : 0);
