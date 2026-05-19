%% Task 1 figures: non-convex expressions & convexification in AC SCOPF
% Reproduces the 6-panel layout (3 non-convex + 3 convexification panels).
% Run from the coursework folder. Figures are saved to ./figures_task1/
%
% Requirements: MATLAB R2019b+ (tiledlayout, exportgraphics).
%               Older versions: replace tiledlayout -> subplot; exportgraphics -> print.

clear; close all; clc;

outDir = fullfile(pwd, 'figures_task1');
if ~exist(outDir, 'dir'), mkdir(outDir); end
makePDF = false;

% ── Global style ──────────────────────────────────────────────────────────
set(groot, 'defaultFigureColor',              'w');
set(groot, 'defaultAxesFontName',             'Times New Roman');
set(groot, 'defaultTextInterpreter',          'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter',        'latex');

BLUE   = [0.11  0.36  0.62];
RED    = [0.74  0.18  0.16];
GREEN  = [0.08  0.38  0.23];
GREY   = [0.35  0.35  0.35];
PURPLE = [0.42  0.25  0.63];

% ── Shared data ────────────────────────────────────────────────────────────
vi_v = linspace(0.90, 1.10, 101);
vj_v = linspace(0.90, 1.10, 101);
[VI_b, VJ_b] = meshgrid(vi_v, vj_v);
Z_bilin = VI_b .* VJ_b;

theta_v = linspace(-pi, pi, 181);
vi2_v   = linspace(0.90, 1.10, 101);
[TH, VI2] = meshgrid(theta_v, vi2_v);
Vj0    = 1.0;  t0 = 1.0;  alpha0 = deg2rad(8);
g      = 0.02; b  = -0.18;
Pij    = g.*(VI2./t0).^2 ...
       - g.*(VI2./t0).*Vj0.*cos(TH - alpha0) ...
       - b.*(VI2./t0).*Vj0.*sin(TH - alpha0); %#ok<NASGU>

theta_circ = linspace(0, 2*pi, 500);
S_loss     = 0.88;   % illustrative loss-equality radius

% ══════════════════════════════════════════════════════════════════════════
%  COMBINED 6-PANEL FIGURE
% ══════════════════════════════════════════════════════════════════════════
fig = figure('Name','Task1 6-panel','Position',[60 60 1400 780]);
tl  = tiledlayout(fig, 2, 3, 'Padding','compact', 'TileSpacing','compact');

% ── Row labels (textbox annotations — no arrow, no ax2fig needed) ──────────
annotation(fig, 'textbox', [0.00 0.52 0.03 0.44], ...
    'String', 'Non-convex expressions', ...
    'Color', RED, 'FontName', 'Times New Roman', 'FontSize', 9, ...
    'FontWeight', 'bold', 'Rotation', 90, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'EdgeColor', 'none', 'Interpreter', 'none');

annotation(fig, 'textbox', [0.00 0.02 0.03 0.44], ...
    'String', 'Convexification & impact', ...
    'Color', BLUE, 'FontName', 'Times New Roman', 'FontSize', 9, ...
    'FontWeight', 'bold', 'Rotation', 90, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'EdgeColor', 'none', 'Interpreter', 'none');

% ── Horizontal divider ─────────────────────────────────────────────────────
annotation(fig, 'line', [0.04 0.99], [0.505 0.505], ...
    'Color', [0.75 0.75 0.75], 'LineWidth', 1.0);

% ─────────────────────────────────────────────────────────────────────────
% (a) 3-D bilinear voltage surface
% ─────────────────────────────────────────────────────────────────────────
ax_a = nexttile(tl, 1);
surf(ax_a, VI_b, VJ_b, Z_bilin, 'EdgeColor', 'none', 'FaceAlpha', 0.92);
colormap(ax_a, parula);
hold(ax_a, 'on');
plot3(ax_a, [0.90 1.10], [1.10 0.90], [0.99 0.99], ...
    'k-', 'LineWidth', 2.0);
plot3(ax_a, 1.00, 1.00, 1.00, 'o', ...
    'MarkerFaceColor', RED, 'MarkerEdgeColor', 'w', 'MarkerSize', 7);
xlabel(ax_a, '$|V_i|$ [pu]');
ylabel(ax_a, '$|V_j|$ [pu]');
zlabel(ax_a, '$|V_i||V_j|$');
title(ax_a, '(a) Non-convex: bilinear $|V_i||V_j|$\newline(AC branch power flow)');
view(ax_a, 135, 25);
grid(ax_a, 'on');  box(ax_a, 'on');

% ─────────────────────────────────────────────────────────────────────────
% (b) PST angle coupling P_ij(alpha)
% ─────────────────────────────────────────────────────────────────────────
ax_b = nexttile(tl, 2);
alpha_v = linspace(-deg2rad(30), deg2rad(30), 200);
P_alpha = g - g.*cos(alpha_v - alpha0) - b.*sin(alpha_v - alpha0);
p_lo    = P_alpha(1);
p_hi    = P_alpha(end);
chord_a = p_lo + (p_hi - p_lo) .* ...
          (alpha_v - alpha_v(1)) ./ (alpha_v(end) - alpha_v(1));

hold(ax_b, 'on');
fill(ax_b, ...
    [rad2deg(alpha_v), fliplr(rad2deg(alpha_v))], ...
    [P_alpha,          fliplr(chord_a)], ...
    GREEN, 'FaceAlpha', 0.20, 'EdgeColor', 'none');
plot(ax_b, rad2deg(alpha_v), P_alpha, '-',  'Color', BLUE, 'LineWidth', 2.0);
plot(ax_b, rad2deg(alpha_v), chord_a, '--', 'Color', RED,  'LineWidth', 1.8);
yline(ax_b, 0, ':', 'Color', GREY, 'LineWidth', 0.8);
xlabel(ax_b, '$\alpha$ [deg]');
ylabel(ax_b, '$P_{ij}(\alpha)$ [pu]');
title(ax_b, ['(b) Non-convex: PST angle coupling' newline ...
             '$P_{ij}(\alpha)$ --- bilinear in $t_{ij},\,\alpha_{ij}$']);
legend(ax_b, 'non-convex gap', '$P_{ij}(\alpha)$', 'chord', ...
    'Location', 'northwest');
xlim(ax_b, [-30 30]);
grid(ax_b, 'on');  box(ax_b, 'on');

% ─────────────────────────────────────────────────────────────────────────
% (c) Converter loss equality in P-Q plane
% ─────────────────────────────────────────────────────────────────────────
ax_c = nexttile(tl, 3);
hold(ax_c, 'on');
fill(ax_c, S_loss.*cos(theta_circ), S_loss.*sin(theta_circ), ...
    RED, 'FaceAlpha', 0.10, 'EdgeColor', 'none');
plot(ax_c, cos(theta_circ), sin(theta_circ), ...
    ':', 'Color', GREY, 'LineWidth', 1.4);
plot(ax_c, S_loss.*cos(theta_circ), S_loss.*sin(theta_circ), ...
    '--', 'Color', RED, 'LineWidth', 2.0);
axis(ax_c, 'equal');
xlim(ax_c, [-1.35 1.35]);  ylim(ax_c, [-1.35 1.35]);
xlabel(ax_c, '$P^{ac}$');  ylabel(ax_c, '$Q^{ac}$');
title(ax_c, ['(c) Non-convex: converter loss equality' newline ...
             '$P^{ac}_c + P^{dc}_c = P^{loss}_c$']);
legend(ax_c, '', 'unit circle', 'loss equality (non-convex)', ...
    'Location', 'northeast');
grid(ax_c, 'on');  box(ax_c, 'on');

% ─────────────────────────────────────────────────────────────────────────
% (d) SOC relaxation — AC branch (W-space disk vs 1-D manifold)
% ─────────────────────────────────────────────────────────────────────────
ax_d = nexttile(tl, 4);
R  = 0.7;
Wc = R .* cos(theta_circ);
Ws = R .* sin(theta_circ);

hold(ax_d, 'on');
fill(ax_d, Wc, Ws, BLUE, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
plot(ax_d, Wc, Ws, '-', 'Color', BLUE, 'LineWidth', 2.0);

rng(42);
r_pts = R .* sqrt(rand(35, 1));
t_pts = 2*pi .* rand(35, 1);
scatter(ax_d, r_pts.*cos(t_pts), r_pts.*sin(t_pts), ...
    22, BLUE, 'filled', 'MarkerFaceAlpha', 0.7);

plot(ax_d, Wc, Ws, '-', 'Color', RED, 'LineWidth', 2.0);

text(ax_d, 0.38, 0.80, {'Extra feasible', 'points (relaxation)'}, ...
    'Color', BLUE, 'FontSize', 8, 'FontName', 'Times New Roman', ...
    'Interpreter', 'none');

axis(ax_d, 'equal');
xlim(ax_d, [-1.1 1.1]);  ylim(ax_d, [-1.1 1.1]);
xlabel(ax_d, '$W^c_{ij}=|V_i||V_j|\cos\theta_{ij}$');
ylabel(ax_d, '$W^s_{ij}=|V_i||V_j|\sin\theta_{ij}$');
title(ax_d, ['(d) SOC relaxation (AC branch)' newline ...
             'Equality $\to$ Inequality: solution space expands']);
legend(ax_d, '', ...
    'SOC ineq.\ $\leq$ (convex, 2-D disk)', ...
    '', ...
    'Equality $(W^c)^2\!+\!(W^s)^2\!=\!W_iW_j$ (non-convex)', ...
    'Location', 'southeast');
grid(ax_d, 'on');  box(ax_d, 'on');

% ─────────────────────────────────────────────────────────────────────────
% (e) McCormick envelope + lifted cuts (PST bilinear)
% ─────────────────────────────────────────────────────────────────────────
ax_e = nexttile(tl, 5);
t_arr = linspace(0.5, 1.5, 200);
z_bil = t_arr .^ 2;          % z = t*w, w = t (illustrative)
tL = 0.5;  tU = 1.5;
wL = 0.5;  wU = 1.5;

mc_lo1 = tL.*t_arr + wL.*t_arr - tL*wL;
mc_lo2 = tU.*t_arr + wU.*t_arr - tU*wU;
mc_hi1 = tU.*t_arr + wL.*t_arr - tU*wL;
mc_hi2 = tL.*t_arr + wU.*t_arr - tL*wU;
mc_lo  = max(mc_lo1, mc_lo2);
mc_hi  = min(mc_hi1, mc_hi2);

lift_lo = z_bil - 0.08*(tU - tL);
lift_hi = z_bil + 0.08*(tU - tL);

hold(ax_e, 'on');
fill(ax_e, [t_arr, fliplr(t_arr)], [mc_lo, fliplr(mc_hi)], ...
    GREEN,  'FaceAlpha', 0.20, 'EdgeColor', 'none');
fill(ax_e, [t_arr, fliplr(t_arr)], [lift_lo, fliplr(lift_hi)], ...
    PURPLE, 'FaceAlpha', 0.28, 'EdgeColor', 'none');
yline(ax_e, tL*wL, ':', 'Color', [0.85 0.15 0.85], 'LineWidth', 1.0);
yline(ax_e, tU*wU, ':', 'Color', [0.85 0.15 0.85], 'LineWidth', 1.0);
plot(ax_e, t_arr, z_bil,  '-',  'Color', RED,   'LineWidth', 2.2);
plot(ax_e, t_arr, mc_lo,  '--', 'Color', GREEN, 'LineWidth', 1.4);
plot(ax_e, t_arr, mc_hi,  '--', 'Color', GREEN, 'LineWidth', 1.4);

xlim(ax_e, [0.5 1.5]);  ylim(ax_e, [0.3 1.8]);
xlabel(ax_e, 'Tap ratio $t_{ij}$');
ylabel(ax_e, '$z = t_{ij}\cdot W^c_{ij}$');
title(ax_e, ['(e) McCormick + lifted cuts (PST)' newline ...
             'Bilinear $\to$ convex envelope: solution space shrinks toward exact']);
legend(ax_e, ...
    'McCormick envelope (convex)', ...
    'Lifted cuts --- tighter region', ...
    '', '', ...
    'Bilinear $z=t_{ij}\cdot W^c_{ij}$ (non-convex)', ...
    'Location', 'northwest');
grid(ax_e, 'on');  box(ax_e, 'on');

% ─────────────────────────────────────────────────────────────────────────
% (f) SOC reformulation — converter (P-Q disk)
% ─────────────────────────────────────────────────────────────────────────
ax_f = nexttile(tl, 6);
hold(ax_f, 'on');
fill(ax_f, cos(theta_circ), sin(theta_circ), ...
    BLUE, 'FaceAlpha', 0.13, 'EdgeColor', 'none');
plot(ax_f, cos(theta_circ), sin(theta_circ), ...
    '-', 'Color', BLUE, 'LineWidth', 2.0);
plot(ax_f, S_loss.*cos(theta_circ), S_loss.*sin(theta_circ), ...
    '--', 'Color', RED, 'LineWidth', 2.0);
plot(ax_f, cos(theta_circ), sin(theta_circ), ...
    ':', 'Color', GREY, 'LineWidth', 1.2);

text(ax_f, -1.30, 1.10, {'Relaxation', 'region'}, ...
    'Color', BLUE, 'FontSize', 8, 'FontName', 'Times New Roman', ...
    'Interpreter', 'none');

axis(ax_f, 'equal');
xlim(ax_f, [-1.35 1.35]);  ylim(ax_f, [-1.35 1.35]);
xlabel(ax_f, '$P^{ac}$');  ylabel(ax_f, '$Q^{ac}$');
title(ax_f, ['(f) SOC reformulation (converter)' newline ...
             'Loss equality $\to$ convex disk: solution space expands']);
legend(ax_f, '', ...
    'SOC disk (convex) $(P^{ac})^2\!+\!(Q^{ac})^2\!\leq\!S^2$', ...
    'Loss equality (non-convex)', ...
    'Location', 'southeast');
grid(ax_f, 'on');  box(ax_f, 'on');

% ── Save ───────────────────────────────────────────────────────────────────
saveFigure(fig, outDir, 'task1_combined_6panel', makePDF);
disp(['Done. Figure saved to: ' outDir]);

% ══════════════════════════════════════════════════════════════════════════
function saveFigure(fig, outDir, baseName, makePDF)
    pngPath = fullfile(outDir, [baseName '.png']);
    try
        exportgraphics(fig, pngPath, 'Resolution', 300);
    catch
        print(fig, pngPath, '-dpng', '-r300');
    end
    if makePDF
        pdfPath = fullfile(outDir, [baseName '.pdf']);
        try
            exportgraphics(fig, pdfPath, 'ContentType', 'vector');
        catch
            print(fig, pdfPath, '-dpdf', '-bestfit');
        end
    end
end