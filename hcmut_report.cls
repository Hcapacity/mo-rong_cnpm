\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hcmut_report}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}

% ========================================
% Package Loading
% ========================================

% Font and encoding
\RequirePackage{fontspec}

% Page layout and geometry
\RequirePackage[paper=a4paper,top=1cm,bottom=1cm,left=2.5cm,right=1.5cm,includeheadfoot=true,headheight=30pt]{geometry}
\RequirePackage[absolute,overlay]{textpos}

% Mathematics packages
\RequirePackage{amsmath, amsfonts, amssymb, amsthm}

% Graphics and figures
\RequirePackage{graphicx}
\RequirePackage{float}
\floatplacement{table}{!htbp}
\floatplacement{figure}{!htbp}
\floatplacement{algorithm}{!htbp}

\renewcommand{\topfraction}{0.9}      % Allow top figures to take 90%
\renewcommand{\textfraction}{0.1}     % Require at least 10% text
\renewcommand{\floatpagefraction}{1}

\RequirePackage{caption}
\RequirePackage{subcaption}

% Tables
\RequirePackage{booktabs}
\RequirePackage{makecell}
\RequirePackage{longtable}
\RequirePackage{adjustbox}
\RequirePackage{array}
\RequirePackage{siunitx}
\sisetup{detect-mode, group-digits=false}
\RequirePackage{tabularray}
\UseTblrLibrary{booktabs}

% Colors and boxes
\RequirePackage{xcolor}
\RequirePackage{tcolorbox}

% TikZ for graphics
\RequirePackage{tikz}
\usetikzlibrary{calc,shapes,arrows,positioning}

% Lists and formatting
\RequirePackage{enumitem}
\RequirePackage{placeins}
\RequirePackage{parskip}

% Headers, footers, and references
\RequirePackage{fancyhdr}
\RequirePackage{hyperref}
\RequirePackage{lastpage}
\RequirePackage{minted} % This should appear before csquotes to avoid conflicts
\RequirePackage{csquotes}
\RequirePackage[backend=biber,style=numeric,sorting=none]{biblatex}
\addbibresource{references.bib}

% Utility packages
\RequirePackage{pgffor} % For loops
\RequirePackage{xstring} % For string manipulation
\RequirePackage{multicol}
\RequirePackage{stackrel}
\RequirePackage{hyphenat}
\RequirePackage[english]{babel}
\RequirePackage[linesnumbered,ruled,vlined]{algorithm2e}

% Configure textpos
\setlength{\TPVertModule}{1cm}  % Set vertical measurement units to cm
\setlength{\TPHorizModule}{1cm}  % Set horizontal measurement units to cm

\linespread{1.4}
\setlength{\parindent}{0pt}

\ExplSyntaxOn
% Month name handler using LaTeX3
\cs_new:Npn \__hcmut_month_name: {
  \int_case:nn { \month } {
    {1} {January}
    {2} {February}
    {3} {March}
    {4} {April}
    {5} {May}
    {6} {June}
    {7} {July}
    {8} {August}
    {9} {September}
    {10} {October}
    {11} {November}
    {12} {December}
  }
}
\cs_new_eq:NN \Month \__hcmut_month_name:

% Define document metadata using LaTeX3 token lists
\tl_new:N \l__hcmut_upperuniname_tl
\tl_new:N \l__hcmut_uniname_tl
\tl_new:N \l__hcmut_deptname_tl
\tl_new:N \l__hcmut_coursename_tl
\tl_new:N \l__hcmut_classname_tl
\tl_new:N \l__hcmut_reporttype_tl
\tl_new:N \l__hcmut_reportplace_tl
\tl_new:N \l__hcmut_reporttime_tl
\tl_new:N \l__hcmut_footerinfo_tl
\tl_new:N \l__hcmut_advisor_tl
\tl_new:N \l__hcmut_student_tl

% Set default values
\tl_set:Nn \l__hcmut_upperuniname_tl {Vietnam~National~University~-~Ho~Chi~Minh~City}
\tl_set:Nn \l__hcmut_uniname_tl {Ho~Chi~Minh~City~University~of~Technology}
\tl_set:Nn \l__hcmut_deptname_tl {\textbf{Faculty~of~Computer~Science~and~Engineering}}
\tl_set:Nn \l__hcmut_coursename_tl {Course~name}
\tl_set:Nn \l__hcmut_classname_tl {Class~name}
\tl_set:Nn \l__hcmut_reporttype_tl {Assignment~Report}
\tl_set:Nn \l__hcmut_reportplace_tl {Ho~Chi~Minh~City}
\tl_set:Nn \l__hcmut_reporttime_tl {\Month\c_space_tl\int_use:N\year}
\tl_set:Nn \l__hcmut_footerinfo_tl {Computer~Architecture~Assignment~Report~-~Semester~XXX}

% Title token list
\tl_new:N \l__hcmut_title_tl
\tl_set:Nn \l__hcmut_title_tl {Report~title}

% User-facing commands to set values
\NewDocumentCommand{\upperuniname}{m}{\tl_set:Nn \l__hcmut_upperuniname_tl {#1}}
\NewDocumentCommand{\uniname}{m}{\tl_set:Nn \l__hcmut_uniname_tl {#1}}
\NewDocumentCommand{\deptname}{m}{\tl_set:Nn \l__hcmut_deptname_tl {#1}}
\NewDocumentCommand{\coursename}{m}{\tl_set:Nn \l__hcmut_coursename_tl {#1}}
\NewDocumentCommand{\classname}{m}{\tl_set:Nn \l__hcmut_classname_tl {#1}}
\NewDocumentCommand{\reporttype}{m}{\tl_set:Nn \l__hcmut_reporttype_tl {#1}}
\NewDocumentCommand{\reportplace}{m}{\tl_set:Nn \l__hcmut_reportplace_tl {#1}}
\NewDocumentCommand{\reporttime}{m}{\tl_set:Nn \l__hcmut_reporttime_tl {#1}}
\NewDocumentCommand{\footerinfo}{m}{\tl_set:Nn \l__hcmut_footerinfo_tl {#1}}
\RenewDocumentCommand{\title}{m}{\tl_set:Nn \l__hcmut_title_tl {#1}}

% Advisor command - processes multi-line verbatim input
\NewDocumentCommand{\advisor}{+v}{
  \seq_set_split:Nnn \l_tmpa_seq { \obeyedline } {#1}
  \seq_remove_all:Nn \l_tmpa_seq {}
  \tl_set:Nx \l__hcmut_advisor_tl {& \seq_use:Nn \l_tmpa_seq {} & \\}
}

% Student command - processes multi-line comma-separated verbatim input
\NewDocumentCommand{\student}{+v}{
  \seq_set_split:Nnn \l_tmpa_seq { \obeyedline } {#1}
  \seq_remove_all:Nn \l_tmpa_seq {}
  \tl_clear:N \l__hcmut_student_tl
  \seq_map_inline:Nn \l_tmpa_seq {
    \seq_set_split:Nnn \l_tmpb_seq { , } {##1}
    \tl_put_right:Nx \l__hcmut_student_tl { & \seq_use:Nn \l_tmpb_seq { & } \\}
  }
}

\definecolor{blueLogo-dark}{RGB}{3, 43, 145}
\definecolor{blueLogo-light}{RGB}{20, 136, 219}

\NewDocumentCommand{\coverpage}{}{
  \newgeometry{top=2cm, bottom=2cm, left=2.5cm, right=1.5cm, includeheadfoot=true, headheight=40pt}
  \begin{tikzpicture}[remember~picture,overlay,inner~sep=0,outer~sep=0]
    % --- Coordinate Definitions ---
    % Define the primary page corners for cleaner math
    \coordinate (PageNE) at (current~page.north~east);
    \coordinate (PageNW) at (current~page.north~west);
    \coordinate (PageSW) at (current~page.south~west);
    \coordinate (PageSE) at (current~page.south~east);

    % Define the main border anchor points using math offsets instead of xshift/yshift
    \coordinate (A) at ($(PageNE) + (-1.5, -1.5)$);
    \coordinate (B) at ($(PageNW) + (2.5, -1.5)$);
    \coordinate (C) at ($(PageSW) + (2.5, 1.5)$);
    \coordinate (D) at ($(PageSE) + (-1.5, 1.5)$);

    % --- Drawing Commands ---
    \draw [blueLogo-dark, ~line~width=4pt] (A) rectangle (C);

    \draw [blueLogo-light, ~line~width=1.5pt]
    ($(A) + (-0.5, 0.5)$) -- ($(B) + (0.5, 0.5)$) --
    ($(B) + (0.5, -0.5)$) -- ($(B) + (-0.5, -0.5)$) --
    ($(C) + (-0.5, 0.5)$) -- ($(C) + (0.5, 0.5)$) --
    ($(C) + (0.5, -0.5)$) -- ($(D) + (-0.5, -0.5)$) --
    ($(D) + (-0.5, 0.5)$) -- ($(D) + (0.5, 0.5)$) --
    ($(A) + (0.5, -0.5)$) -- ($(A) + (-0.5, -0.5)$) -- cycle;

    \draw [blueLogo-light, ~line~width=1.5pt]
    ($(A) + (0.3, -0.3)$) -- ($(B) + (-0.3, -0.3)$) --
    ($(B) + (-0.3, 0.3)$) -- ($(B) + (0.3, 0.3)$) --
    ($(C) + (0.3, -0.3)$) -- ($(C) + (-0.3, -0.3)$) --
    ($(C) + (-0.3, 0.3)$) -- ($(D) + (0.3, 0.3)$) --
    ($(D) + (0.3, -0.3)$) -- ($(D) + (-0.3, -0.3)$) --
    ($(A) + (-0.3, 0.3)$) -- ($(A) + (0.3, 0.3)$) -- cycle;

  \end{tikzpicture}

  \pagestyle{empty}

  \vspace*{-3\baselineskip}
  \begin{center}
    \text_uppercase:n {\tl_use:N \l__hcmut_upperuniname_tl}\\
    \text_uppercase:n {\tl_use:N \l__hcmut_uniname_tl}\\
    \text_uppercase:n {\tl_use:N \l__hcmut_deptname_tl}\\
    \vfill
    \includegraphics[scale=0.4]{images/hcmut.png}
    \vfill
    \bfseries
    \begin{tabular}{c}
      \large\tl_use:N \l__hcmut_coursename_tl\\
      \midrule
      \Large\tl_use:N \l__hcmut_reporttype_tl\\
      {}\\
      \linespread{1}\selectfont
      \LARGE\parbox[c]{0.8\linewidth}{\centering \tl_use:N \l__hcmut_title_tl}\\
      {}\\
      \bottomrule
    \end{tabular}
    \vfill
    \large \tl_use:N \l__hcmut_classname_tl
    \vfill
    \mdseries
    \begin{tabular}{llr}
      Advisor(s): \tl_use:N \l__hcmut_advisor_tl
      Student(s): \tl_use:N \l__hcmut_student_tl
    \end{tabular}
    \vfill
    \begin{tikzpicture}[overlay, remember~picture]
      \node at ($(current~page.south) + (0cm, 2cm)$) [anchor=south, text~width=20cm, align=center] {
        \text_uppercase:n {\tl_use:N \l__hcmut_reportplace_tl,~\tl_use:N \l__hcmut_reporttime_tl}
      };
    \end{tikzpicture}
  \end{center}
  \newpage
  \restoregeometry
  \tableofcontents
  \newpage
  \pagestyle{fancy}
  \setcounter{page}{1}
}

% Prevent underfull vbox warnings
\raggedbottom

% Set depth of numbering for sections and table of contents
\setcounter{secnumdepth}{4}
\setcounter{tocdepth}{3}

% Set depth of numbering for counters
\AtBeginDocument{\counterwithin{equation}{section}}
\AtBeginDocument{\counterwithin{table}{section}}
\AtBeginDocument{\counterwithin{figure}{section}}
\AtBeginDocument{\counterwithin{algocf}{section}}

\AtBeginDocument{\renewcommand*\bibname{References}}

% Configure hyperlink colors and styles
\hypersetup{
  colorlinks=true,
  linkcolor=black,
  citecolor=blue,
  urlcolor=blue
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Header and Footer Configuration %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\renewcommand{\headrulewidth}{0.3pt}
\renewcommand{\footrulewidth}{0.3pt}
\pagestyle{fancy}
\fancyhf{}

\if@twoside
\fancyhead[LO]{
  \bfseries
  \raisebox{-8pt}{\includegraphics[scale=0.08]{images/hcmut.png}}
  \begin{tabular}{l}
    \ttfamily \tl_use:N \l__hcmut_uniname_tl \\
    \ttfamily \tl_use:N \l__hcmut_deptname_tl \\
  \end{tabular}
}
\fancyhead[RE]{
  \bfseries
  \begin{tabular}{r}
    \ttfamily \tl_use:N \l__hcmut_uniname_tl \\
    \ttfamily \tl_use:N \l__hcmut_deptname_tl \\
  \end{tabular}
  \raisebox{-8pt}{\includegraphics[scale=0.08]{images/hcmut.png}}
}
\fancyfoot[LO]{\scriptsize \ttfamily Page~\thepage/\pageref{LastPage}}
\fancyfoot[RO]{\scriptsize \ttfamily \tl_use:N \l__hcmut_footerinfo_tl}
\fancyfoot[LE]{\scriptsize \ttfamily \tl_use:N \l__hcmut_footerinfo_tl}
\fancyfoot[RE]{\scriptsize \ttfamily Page~\thepage/\pageref{LastPage}}
\else
\fancyhead[R]{
  \bfseries
  \begin{tabular}{r}
    \ttfamily \tl_use:N \l__hcmut_uniname_tl \\
    \ttfamily \tl_use:N \l__hcmut_deptname_tl \\
  \end{tabular}
  \raisebox{-8pt}{\includegraphics[scale=0.08]{images/hcmut.png}}
}
\fancyfoot[L]{\scriptsize \ttfamily Page~\thepage/\pageref{LastPage}}
\fancyfoot[R]{\scriptsize \ttfamily \tl_use:N \l__hcmut_footerinfo_tl}
\fi
\ExplSyntaxOff