/* dwm config.h - Versão CORRIGIDA para Pablo */
#include <X11/XF86keysym.h>

/* Tags */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

/* Aparência */
static const unsigned int borderpx  = 1;
static const unsigned int snap      = 32;
static const int showbar            = 1;
static const int topbar             = 1;

/* Fontes */
static const char *fonts[] = { "monospace:size=10" };
static const char dmenufont[] = "monospace:size=10";

/* Cores fixas */
static const char normbgcolor[] = "#222222";
static const char normfgcolor[] = "#bbbbbb";
static const char selbgcolor[]  = "#005577";
static const char selfgcolor[]  = "#eeeeee";

/* Esquemas de cores */
static const char *colors[][3] = {
    /*               fg         bg         border   */
    [SchemeNorm] = { normfgcolor, normbgcolor, "#444444" },
    [SchemeSel]  = { selfgcolor, selbgcolor, selbgcolor },
};

/* Layouts */
static const Layout layouts[] = {
    { "[]=",      tile },
    { "><>",      NULL },
    { "[M]",      monocle },
};

/* Variáveis de layout */
static const int nmaster = 1;
static const int resizehints = 1;
static const int lockfullscreen = 1;
static const float mfact = 0.55;

/* Variável refreshrate */
static const unsigned int refreshrate = 60;

/* Aplicativos */
static const char *termcmd[]  = { "xterm", NULL };
static const char *firefoxcmd[] = { "firefox", NULL };
static const char *filemanagercmd[] = { "caja", NULL };
static const char *rofidcmd[] = { "rofi", "-show", "drun", NULL };
static const char *screenshotcmd[] = { "scrot", NULL };
static const char *screenshotselectcmd[] = { "scrot", "-s", NULL };

/* dmenu */
static const char *dmenucmd[] = { 
    "dmenu_run", 
    "-m", "0", 
    "-fn", dmenufont, 
    "-nb", normbgcolor, 
    "-nf", normfgcolor, 
    "-sb", selbgcolor, 
    "-sf", selfgcolor, 
    NULL 
};

/* dmenumon */
static char dmenumon[2] = "0";

/* Modkey */
#define MODKEY Mod4Mask

/* Teclas de atalho */
static const Key keys[] = {
    /* Aplicativos */
    { MODKEY,                       XK_a,      spawn,          {.v = termcmd } },
    { MODKEY,                       XK_n,      spawn,          {.v = filemanagercmd } },
    { MODKEY,                       XK_o,      spawn,          {.v = firefoxcmd } },
    { MODKEY,                       XK_c,      spawn,          {.v = rofidcmd } },
    { MODKEY,                       XK_p,      spawn,          {.v = screenshotcmd } },
    { MODKEY|ShiftMask,             XK_p,      spawn,          {.v = screenshotselectcmd } },
    { MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },

    /* Layouts */
    { MODKEY,                       XK_f,      setlayout,      {.v = &layouts[0]} },
    { MODKEY|ShiftMask,             XK_f,      setlayout,      {.v = &layouts[1]} },
    { MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
    { MODKEY,                       XK_space,  setlayout,      {0} },
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },

    /* Foco */
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
    { MODKEY,                       XK_Return, zoom,           {0} },
    { MODKEY,                       XK_Tab,    view,           {0} },

    /* Tags 1-9 */
    { MODKEY,                       XK_1,      view,           {.ui = 1 << 0} },
    { MODKEY,                       XK_2,      view,           {.ui = 1 << 1} },
    { MODKEY,                       XK_3,      view,           {.ui = 1 << 2} },
    { MODKEY,                       XK_4,      view,           {.ui = 1 << 3} },
    { MODKEY,                       XK_5,      view,           {.ui = 1 << 4} },
    { MODKEY,                       XK_6,      view,           {.ui = 1 << 5} },
    { MODKEY,                       XK_7,      view,           {.ui = 1 << 6} },
    { MODKEY,                       XK_8,      view,           {.ui = 1 << 7} },
    { MODKEY,                       XK_9,      view,           {.ui = 1 << 8} },
    
    { MODKEY|ShiftMask,             XK_1,      tag,            {.ui = 1 << 0} },
    { MODKEY|ShiftMask,             XK_2,      tag,            {.ui = 1 << 1} },
    { MODKEY|ShiftMask,             XK_3,      tag,            {.ui = 1 << 2} },
    { MODKEY|ShiftMask,             XK_4,      tag,            {.ui = 1 << 3} },
    { MODKEY|ShiftMask,             XK_5,      tag,            {.ui = 1 << 4} },
    { MODKEY|ShiftMask,             XK_6,      tag,            {.ui = 1 << 5} },
    { MODKEY|ShiftMask,             XK_7,      tag,            {.ui = 1 << 6} },
    { MODKEY|ShiftMask,             XK_8,      tag,            {.ui = 1 << 7} },
    { MODKEY|ShiftMask,             XK_9,      tag,            {.ui = 1 << 8} },

    /* Controle */
    { MODKEY,                       XK_q,      killclient,     {0} },
    { MODKEY|ShiftMask,             XK_q,      quit,           {0} },

    /* Print Screen */
    { 0,                            XK_Print,  spawn,          {.v = screenshotcmd } },
    { ShiftMask,                    XK_Print,  spawn,          {.v = screenshotselectcmd } },
};

/* Regras - com pelo menos uma regra dummy para não ficar vazio */
static const Rule rules[] = {
    /* Classe      Instância    Titulo  Tags Mask  Isfloating Monitor */
    { "Gimp",     NULL,       NULL,    0,         1,        -1 },
};

/* Botões do mouse */
static const Button buttons[] = {
    { ClkLtSymbol,      0,        Button1,   setlayout,    {0} },
    { ClkLtSymbol,      0,        Button3,   setlayout,    {.v = &layouts[2]} },
    { ClkWinTitle,      0,        Button2,   zoom,         {0} },
    { ClkStatusText,    0,        Button2,   spawn,        {.v = termcmd } },
    { ClkClientWin,     MODKEY,   Button1,   movemouse,    {0} },
    { ClkClientWin,     MODKEY,   Button2,   togglefloating, {0} },
    { ClkClientWin,     MODKEY,   Button3,   resizemouse,  {0} },
    { ClkTagBar,        0,        Button1,   view,         {0} },
    { ClkTagBar,        0,        Button3,   toggleview,   {0} },
    { ClkTagBar,        MODKEY,   Button1,   tag,          {0} },
    { ClkTagBar,        MODKEY,   Button3,   toggletag,    {0} },
}
