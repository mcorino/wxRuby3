// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

%module(directors="1") wxRubyConstants

%include "common.i"

%{
#include <wx/gdicmn.h>
#include <wx/fdrepdlg.h>
#include <wx/artprov.h>
#include <wx/calctrl.h>
#include <wx/treebase.h>
#include <wx/image.h>
#include <wx/imaglist.h>
#include <wx/laywin.h>
#include <wx/imagbmp.h>
#include <wx/sashwin.h>
#include <wx/prntbase.h>
#include <wx/listbase.h>
#include <wx/animate.h>

extern VALUE mWxCore;
%}

#ifdef __WXRB_DEBUG__
%constant const bool wxRB_DEBUG = true;
#else
%constant const bool wxRB_DEBUG = false;
#endif

#ifdef __WXRB_TRACE__
%constant const bool wxRB_TRACE = true;
#else
%constant const bool wxRB_TRACE = false;
#endif

//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/defs.h
////** ---------------------------------------------------------------------------- **
//
////  ----------------------------------------------------------------------------
////  OS mnemonics -- Identify the running OS (useful for Windows)
////  ----------------------------------------------------------------------------
//
////  Not all platforms are currently available or supported
///*
//enum
//{
//    wxUNKNOWN_PLATFORM,
//    wxCURSES,                 // Text-only CURSES
//    wxXVIEW_X,                // Sun's XView OpenLOOK toolkit
//    wxMOTIF_X,                // OSF Motif 1.x.x
//    wxCOSE_X,                 // OSF Common Desktop Environment
//    wxNEXTSTEP,               // NeXTStep
//    wxMAC,                    // Apple Mac OS 8/9/X with Mac paths
//    wxMAC_DARWIN,             // Apple Mac OS X with Unix paths
//    wxBEOS,                   // BeOS
//    wxGTK,                    // GTK on X
//    wxGTK_WIN32,              // GTK on Win32
//    wxGTK_OS2,                // GTK on OS/2
//    wxGTK_BEOS,               // GTK on BeOS
//    wxGEOS,                   // GEOS
//    wxOS2_PM,                 // OS/2 Workplace
//    wxWINDOWS,                // Windows or WfW
//    wxMICROWINDOWS,           // MicroWindows
//    wxPENWINDOWS,             // Windows for Pen Computing
//    wxWINDOWS_NT,             // Windows NT
//    wxWIN32S,                 // Windows 32S API
//    wxWIN95,                  // Windows 95
//    wxWIN386,                 // Watcom 32-bit supervisor modus
//    wxWINDOWS_CE,             // Windows CE (generic)
//    wxWINDOWS_POCKETPC,       // Windows CE PocketPC
//    wxWINDOWS_SMARTPHONE,     // Windows CE Smartphone
//    wxMGL_UNIX,               // MGL with direct hardware access
//    wxMGL_X,                  // MGL on X
//    wxMGL_WIN32,              // MGL on Win32
//    wxMGL_OS2,                // MGL on OS/2
//    wxMGL_DOS,                // MGL on MS-DOS
//    wxWINDOWS_OS2,            // Native OS/2 PM
//    wxUNIX,                   // wxBase under Unix
//    wxX11,                    // Plain X11 and Universal widgets
//    wxPALMOS,                 // PalmOS
//    wxDOS                     // wxBase under MS-DOS
//};
//*/
//
//// ----------------------------------------------------------------------------
//// other constants
//// ----------------------------------------------------------------------------
//
//// ----------------------------------------------------------------------------
//// Indexes for SystemSettings static functions
//// ----------------------------------------------------------------------------
//
//// menu and toolbar item kinds
//enum wxItemKind
//{
//    wxITEM_SEPARATOR = -1,
//    wxITEM_NORMAL,
//    wxITEM_CHECK,
//    wxITEM_RADIO,
//    wxITEM_MAX
//};
//
//// hit test results
//enum wxHitTest
//{
//    wxHT_NOWHERE,
//
//    // scrollbar
//    wxHT_SCROLLBAR_FIRST = wxHT_NOWHERE,
//    wxHT_SCROLLBAR_ARROW_LINE_1,    // left or upper arrow to scroll by line
//    wxHT_SCROLLBAR_ARROW_LINE_2,    // right or down
//    wxHT_SCROLLBAR_ARROW_PAGE_1,    // left or upper arrow to scroll by page
//    wxHT_SCROLLBAR_ARROW_PAGE_2,    // right or down
//    wxHT_SCROLLBAR_THUMB,           // on the thumb
//    wxHT_SCROLLBAR_BAR_1,           // bar to the left/above the thumb
//    wxHT_SCROLLBAR_BAR_2,           // bar to the right/below the thumb
//    wxHT_SCROLLBAR_LAST,
//
//    // window
//    wxHT_WINDOW_OUTSIDE,            // not in this window at all
//    wxHT_WINDOW_INSIDE,             // in the client area
//    wxHT_WINDOW_VERT_SCROLLBAR,     // on the vertical scrollbar
//    wxHT_WINDOW_HORZ_SCROLLBAR,     // on the horizontal scrollbar
//    wxHT_WINDOW_CORNER,             // on the corner between 2 scrollbars
//
//    wxHT_MAX
//};
//
//// ----------------------------------------------------------------------------
//// Possible SetSize flags
//// ----------------------------------------------------------------------------
//
//// Use internally-calculated width if -1
//#define wxSIZE_AUTO_WIDTH       0x0001
//// Use internally-calculated height if -1
//#define wxSIZE_AUTO_HEIGHT      0x0002
//// Use internally-calculated width and height if each is -1
//#define wxSIZE_AUTO             (wxSIZE_AUTO_WIDTH|wxSIZE_AUTO_HEIGHT)
//// Ignore missing (-1) dimensions (use existing).
//// For readability only: test for wxSIZE_AUTO_WIDTH/HEIGHT in code.
//#define wxSIZE_USE_EXISTING     0x0000
//// Allow -1 as a valid position
//#define wxSIZE_ALLOW_MINUS_ONE  0x0004
//// Don't do parent client adjustments (for implementation only)
//#define wxSIZE_NO_ADJUSTMENTS   0x0008
//
//// ----------------------------------------------------------------------------
//// GDI descriptions
//// ----------------------------------------------------------------------------
//
//enum
//{
//    // Text font families
//    wxDEFAULT    = 70,
//    wxDECORATIVE,
//    wxROMAN,
//    wxSCRIPT,
//    wxSWISS,
//    wxMODERN,
//    wxTELETYPE,  /* @@@@ */
//
//    // Proportional or Fixed width fonts (not yet used)
//    wxVARIABLE   = 80,
//    wxFIXED,
//
//    wxNORMAL     = 90,
//    wxLIGHT,
//    wxBOLD,
//    // Also wxNORMAL for normal (non-italic text)
//    wxITALIC,
//    wxSLANT,
//
//    // Pen styles
//    wxSOLID      =   100,
//    wxDOT,
//    wxLONG_DASH,
//    wxSHORT_DASH,
//    wxDOT_DASH,
//    wxUSER_DASH,
//
//    wxTRANSPARENT,
//
//    // Brush & Pen Stippling. Note that a stippled pen cannot be dashed!!
//    // Note also that stippling a Pen IS meaningfull, because a Line is
//    wxSTIPPLE_MASK_OPAQUE, //mask is used for blitting monochrome using text fore and back ground colors
//    wxSTIPPLE_MASK,        //mask is used for masking areas in the stipple bitmap (TO DO)
//    // drawn with a Pen, and without any Brush -- and it can be stippled.
//    wxSTIPPLE =          110,
//    wxBDIAGONAL_HATCH,
//    wxCROSSDIAG_HATCH,
//    wxFDIAGONAL_HATCH,
//    wxCROSS_HATCH,
//    wxHORIZONTAL_HATCH,
//    wxVERTICAL_HATCH,
//    wxFIRST_HATCH = wxBDIAGONAL_HATCH,
//    wxLAST_HATCH = wxVERTICAL_HATCH,
//
//    wxJOIN_BEVEL =     120,
//    wxJOIN_MITER,
//    wxJOIN_ROUND,
//
//    wxCAP_ROUND =      130,
//    wxCAP_PROJECTING,
//    wxCAP_BUTT
//};
//
//#if WXWIN_COMPATIBILITY_2_4
//    #define IS_HATCH(s)    ((s)>=wxFIRST_HATCH && (s)<=wxLAST_HATCH)
//#else
//    /* use wxBrush::IsHatch() instead thought wxMotif still uses it in src/motif/dcclient.cpp */
//#endif
//
//// Logical ops
//typedef enum
//{
//    wxCLEAR,       // 0
//    wxXOR,         // src XOR dst
//    wxINVERT,      // NOT dst
//    wxOR_REVERSE,  // src OR (NOT dst)
//    wxAND_REVERSE, // src AND (NOT dst)
//    wxCOPY,        // src
//    wxAND,         // src AND dst
//    wxAND_INVERT,  // (NOT src) AND dst
//    wxNO_OP,       // dst
//    wxNOR,         // (NOT src) AND (NOT dst)
//    wxEQUIV,       // (NOT src) XOR dst
//    wxSRC_INVERT,  // (NOT src)
//    wxOR_INVERT,   // (NOT src) OR dst
//    wxNAND,        // (NOT src) OR (NOT dst)
//    wxOR,          // src OR dst
//    wxSET          // 1
//#if WXWIN_COMPATIBILITY_2_8
//    ,wxROP_BLACK = wxCLEAR,
//    wxBLIT_BLACKNESS = wxCLEAR,
//    wxROP_XORPEN = wxXOR,
//    wxBLIT_SRCINVERT = wxXOR,
//    wxROP_NOT = wxINVERT,
//    wxBLIT_DSTINVERT = wxINVERT,
//    wxROP_MERGEPENNOT = wxOR_REVERSE,
//    wxBLIT_00DD0228 = wxOR_REVERSE,
//    wxROP_MASKPENNOT = wxAND_REVERSE,
//    wxBLIT_SRCERASE = wxAND_REVERSE,
//    wxROP_COPYPEN = wxCOPY,
//    wxBLIT_SRCCOPY = wxCOPY,
//    wxROP_MASKPEN = wxAND,
//    wxBLIT_SRCAND = wxAND,
//    wxROP_MASKNOTPEN = wxAND_INVERT,
//    wxBLIT_00220326 = wxAND_INVERT,
//    wxROP_NOP = wxNO_OP,
//    wxBLIT_00AA0029 = wxNO_OP,
//    wxROP_NOTMERGEPEN = wxNOR,
//    wxBLIT_NOTSRCERASE = wxNOR,
//    wxROP_NOTXORPEN = wxEQUIV,
//    wxBLIT_00990066 = wxEQUIV,
//    wxROP_NOTCOPYPEN = wxSRC_INVERT,
//    wxBLIT_NOTSCRCOPY = wxSRC_INVERT,
//    wxROP_MERGENOTPEN = wxOR_INVERT,
//    wxBLIT_MERGEPAINT = wxOR_INVERT,
//    wxROP_NOTMASKPEN = wxNAND,
//    wxBLIT_007700E6 = wxNAND,
//    wxROP_MERGEPEN = wxOR,
//    wxBLIT_SRCPAINT = wxOR,
//    wxROP_WHITE = wxSET,
//    wxBLIT_WHITENESS = wxSET
//#endif //WXWIN_COMPATIBILITY_2_8
//} form_ops_t;
//
//// Flood styles
//enum
//{
//    wxFLOOD_SURFACE = 1,
//    wxFLOOD_BORDER
//};
//
//// Polygon filling mode
//enum
//{
//    wxODDEVEN_RULE = 1,
//    wxWINDING_RULE
//};
//
//// ToolPanel in wxFrame (VZ: unused?)
//enum
//{
//    wxTOOL_TOP = 1,
//    wxTOOL_BOTTOM,
//    wxTOOL_LEFT,
//    wxTOOL_RIGHT
//};
//
//// Virtual keycodes
//enum wxKeyCode
//{
//    WXK_BACK    =    8,
//    WXK_TAB     =    9,
//    WXK_RETURN  =    13,
//    WXK_ESCAPE  =    27,
//    WXK_SPACE   =    32,
//    WXK_DELETE  =    127,
//
//    WXK_START   = 300,
//    WXK_LBUTTON,
//    WXK_RBUTTON,
//    WXK_CANCEL,
//    WXK_MBUTTON,
//    WXK_CLEAR,
//    WXK_SHIFT,
//    WXK_ALT,
//    WXK_CONTROL,
//    WXK_MENU,
//    WXK_PAUSE,
//    WXK_CAPITAL,
//    WXK_END,
//    WXK_HOME,
//    WXK_LEFT,
//    WXK_UP,
//    WXK_RIGHT,
//    WXK_DOWN,
//    WXK_SELECT,
//    WXK_PRINT,
//    WXK_EXECUTE,
//    WXK_SNAPSHOT,
//    WXK_INSERT,
//    WXK_HELP,
//    WXK_NUMPAD0,
//    WXK_NUMPAD1,
//    WXK_NUMPAD2,
//    WXK_NUMPAD3,
//    WXK_NUMPAD4,
//    WXK_NUMPAD5,
//    WXK_NUMPAD6,
//    WXK_NUMPAD7,
//    WXK_NUMPAD8,
//    WXK_NUMPAD9,
//    WXK_MULTIPLY,
//    WXK_ADD,
//    WXK_SEPARATOR,
//    WXK_SUBTRACT,
//    WXK_DECIMAL,
//    WXK_DIVIDE,
//    WXK_F1,
//    WXK_F2,
//    WXK_F3,
//    WXK_F4,
//    WXK_F5,
//    WXK_F6,
//    WXK_F7,
//    WXK_F8,
//    WXK_F9,
//    WXK_F10,
//    WXK_F11,
//    WXK_F12,
//    WXK_F13,
//    WXK_F14,
//    WXK_F15,
//    WXK_F16,
//    WXK_F17,
//    WXK_F18,
//    WXK_F19,
//    WXK_F20,
//    WXK_F21,
//    WXK_F22,
//    WXK_F23,
//    WXK_F24,
//    WXK_NUMLOCK,
//    WXK_SCROLL,
//    WXK_PAGEUP,
//    WXK_PAGEDOWN,
//
//    WXK_NUMPAD_SPACE,
//    WXK_NUMPAD_TAB,
//    WXK_NUMPAD_ENTER,
//    WXK_NUMPAD_F1,
//    WXK_NUMPAD_F2,
//    WXK_NUMPAD_F3,
//    WXK_NUMPAD_F4,
//    WXK_NUMPAD_HOME,
//    WXK_NUMPAD_LEFT,
//    WXK_NUMPAD_UP,
//    WXK_NUMPAD_RIGHT,
//    WXK_NUMPAD_DOWN,
//    WXK_NUMPAD_PAGEUP,
//    WXK_NUMPAD_PAGEDOWN,
//    WXK_NUMPAD_END,
//    WXK_NUMPAD_BEGIN,
//    WXK_NUMPAD_INSERT,
//    WXK_NUMPAD_DELETE,
//    WXK_NUMPAD_EQUAL,
//    WXK_NUMPAD_MULTIPLY,
//    WXK_NUMPAD_ADD,
//    WXK_NUMPAD_SEPARATOR,
//    WXK_NUMPAD_SUBTRACT,
//    WXK_NUMPAD_DECIMAL,
//    WXK_NUMPAD_DIVIDE,
//
//    WXK_WINDOWS_LEFT,
//    WXK_WINDOWS_RIGHT,
//    WXK_WINDOWS_MENU ,
//    WXK_COMMAND,
//
//    // Hardware-specific buttons
//    WXK_SPECIAL1 = 193,
//    WXK_SPECIAL2,
//    WXK_SPECIAL3,
//    WXK_SPECIAL4,
//    WXK_SPECIAL5,
//    WXK_SPECIAL6,
//    WXK_SPECIAL7,
//    WXK_SPECIAL8,
//    WXK_SPECIAL9,
//    WXK_SPECIAL10,
//    WXK_SPECIAL11,
//    WXK_SPECIAL12,
//    WXK_SPECIAL13,
//    WXK_SPECIAL14,
//    WXK_SPECIAL15,
//    WXK_SPECIAL16,
//    WXK_SPECIAL17,
//    WXK_SPECIAL18,
//    WXK_SPECIAL19,
//    WXK_SPECIAL20
//};
//
//
///* This enum contains bit mask constants used in wxKeyEvent */
//enum wxKeyModifier
//{
//    wxMOD_NONE      = 0x0000,
//    wxMOD_ALT       = 0x0001,
//    wxMOD_CONTROL   = 0x0002,
//    wxMOD_ALTGR     = wxMOD_ALT | wxMOD_CONTROL,
//    wxMOD_SHIFT     = 0x0004,
//    wxMOD_META      = 0x0008,
//    wxMOD_WIN       = wxMOD_META,
//#if defined(__WXMAC__) || defined(__WXCOCOA__)
//    wxMOD_CMD       = wxMOD_META,
//#else
//    wxMOD_CMD       = wxMOD_CONTROL,
//#endif
//    wxMOD_ALL       = 0xffff
//};
//
//// Mapping modes (same values as used by Windows, don't change)
//enum
//{
//    wxMM_TEXT = 1,
//    wxMM_LOMETRIC,
//    wxMM_TWIPS,
//    wxMM_POINTS,
//    wxMM_METRIC
//};
//
///* Shortcut for easier dialog-unit-to-pixel conversion */
//#define wxDLG_UNIT(parent, pt) parent->ConvertDialogToPixels(pt)
//
///* Paper types */
//typedef enum
//{
//    wxPAPER_NONE,               // Use specific dimensions
//    wxPAPER_LETTER,             // Letter, 8 1/2 by 11 inches
//    wxPAPER_LEGAL,              // Legal, 8 1/2 by 14 inches
//    wxPAPER_A4,                 // A4 Sheet, 210 by 297 millimeters
//    wxPAPER_CSHEET,             // C Sheet, 17 by 22 inches
//    wxPAPER_DSHEET,             // D Sheet, 22 by 34 inches
//    wxPAPER_ESHEET,             // E Sheet, 34 by 44 inches
//    wxPAPER_LETTERSMALL,        // Letter Small, 8 1/2 by 11 inches
//    wxPAPER_TABLOID,            // Tabloid, 11 by 17 inches
//    wxPAPER_LEDGER,             // Ledger, 17 by 11 inches
//    wxPAPER_STATEMENT,          // Statement, 5 1/2 by 8 1/2 inches
//    wxPAPER_EXECUTIVE,          // Executive, 7 1/4 by 10 1/2 inches
//    wxPAPER_A3,                 // A3 sheet, 297 by 420 millimeters
//    wxPAPER_A4SMALL,            // A4 small sheet, 210 by 297 millimeters
//    wxPAPER_A5,                 // A5 sheet, 148 by 210 millimeters
//    wxPAPER_B4,                 // B4 sheet, 250 by 354 millimeters
//    wxPAPER_B5,                 // B5 sheet, 182-by-257-millimeter paper
//    wxPAPER_FOLIO,              // Folio, 8-1/2-by-13-inch paper
//    wxPAPER_QUARTO,             // Quarto, 215-by-275-millimeter paper
//    wxPAPER_10X14,              // 10-by-14-inch sheet
//    wxPAPER_11X17,              // 11-by-17-inch sheet
//    wxPAPER_NOTE,               // Note, 8 1/2 by 11 inches
//    wxPAPER_ENV_9,              // #9 Envelope, 3 7/8 by 8 7/8 inches
//    wxPAPER_ENV_10,             // #10 Envelope, 4 1/8 by 9 1/2 inches
//    wxPAPER_ENV_11,             // #11 Envelope, 4 1/2 by 10 3/8 inches
//    wxPAPER_ENV_12,             // #12 Envelope, 4 3/4 by 11 inches
//    wxPAPER_ENV_14,             // #14 Envelope, 5 by 11 1/2 inches
//    wxPAPER_ENV_DL,             // DL Envelope, 110 by 220 millimeters
//    wxPAPER_ENV_C5,             // C5 Envelope, 162 by 229 millimeters
//    wxPAPER_ENV_C3,             // C3 Envelope, 324 by 458 millimeters
//    wxPAPER_ENV_C4,             // C4 Envelope, 229 by 324 millimeters
//    wxPAPER_ENV_C6,             // C6 Envelope, 114 by 162 millimeters
//    wxPAPER_ENV_C65,            // C65 Envelope, 114 by 229 millimeters
//    wxPAPER_ENV_B4,             // B4 Envelope, 250 by 353 millimeters
//    wxPAPER_ENV_B5,             // B5 Envelope, 176 by 250 millimeters
//    wxPAPER_ENV_B6,             // B6 Envelope, 176 by 125 millimeters
//    wxPAPER_ENV_ITALY,          // Italy Envelope, 110 by 230 millimeters
//    wxPAPER_ENV_MONARCH,        // Monarch Envelope, 3 7/8 by 7 1/2 inches
//    wxPAPER_ENV_PERSONAL,       // 6 3/4 Envelope, 3 5/8 by 6 1/2 inches
//    wxPAPER_FANFOLD_US,         // US Std Fanfold, 14 7/8 by 11 inches
//    wxPAPER_FANFOLD_STD_GERMAN, // German Std Fanfold, 8 1/2 by 12 inches
//    wxPAPER_FANFOLD_LGL_GERMAN, // German Legal Fanfold, 8 1/2 by 13 inches
//
//    wxPAPER_ISO_B4,             // B4 (ISO) 250 x 353 mm
//    wxPAPER_JAPANESE_POSTCARD,  // Japanese Postcard 100 x 148 mm
//    wxPAPER_9X11,               // 9 x 11 in
//    wxPAPER_10X11,              // 10 x 11 in
//    wxPAPER_15X11,              // 15 x 11 in
//    wxPAPER_ENV_INVITE,         // Envelope Invite 220 x 220 mm
//    wxPAPER_LETTER_EXTRA,       // Letter Extra 9 \275 x 12 in
//    wxPAPER_LEGAL_EXTRA,        // Legal Extra 9 \275 x 15 in
//    wxPAPER_TABLOID_EXTRA,      // Tabloid Extra 11.69 x 18 in
//    wxPAPER_A4_EXTRA,           // A4 Extra 9.27 x 12.69 in
//    wxPAPER_LETTER_TRANSVERSE,  // Letter Transverse 8 \275 x 11 in
//    wxPAPER_A4_TRANSVERSE,      // A4 Transverse 210 x 297 mm
//    wxPAPER_LETTER_EXTRA_TRANSVERSE, // Letter Extra Transverse 9\275 x 12 in
//    wxPAPER_A_PLUS,             // SuperA/SuperA/A4 227 x 356 mm
//    wxPAPER_B_PLUS,             // SuperB/SuperB/A3 305 x 487 mm
//    wxPAPER_LETTER_PLUS,        // Letter Plus 8.5 x 12.69 in
//    wxPAPER_A4_PLUS,            // A4 Plus 210 x 330 mm
//    wxPAPER_A5_TRANSVERSE,      // A5 Transverse 148 x 210 mm
//    wxPAPER_B5_TRANSVERSE,      // B5 (JIS) Transverse 182 x 257 mm
//    wxPAPER_A3_EXTRA,           // A3 Extra 322 x 445 mm
//    wxPAPER_A5_EXTRA,           // A5 Extra 174 x 235 mm
//    wxPAPER_B5_EXTRA,           // B5 (ISO) Extra 201 x 276 mm
//    wxPAPER_A2,                 // A2 420 x 594 mm
//    wxPAPER_A3_TRANSVERSE,      // A3 Transverse 297 x 420 mm
//    wxPAPER_A3_EXTRA_TRANSVERSE, // A3 Extra Transverse 322 x 445 mm
//
//    wxPAPER_DBL_JAPANESE_POSTCARD,// Japanese Double Postcard 200 x 148 mm
//    wxPAPER_A6,                 // A6 105 x 148 mm
//    wxPAPER_JENV_KAKU2,         // Japanese Envelope Kaku #2
//    wxPAPER_JENV_KAKU3,         // Japanese Envelope Kaku #3
//    wxPAPER_JENV_CHOU3,         // Japanese Envelope Chou #3
//    wxPAPER_JENV_CHOU4,         // Japanese Envelope Chou #4
//    wxPAPER_LETTER_ROTATED,     // Letter Rotated 11 x 8 1/2 in
//    wxPAPER_A3_ROTATED,         // A3 Rotated 420 x 297 mm
//    wxPAPER_A4_ROTATED,         // A4 Rotated 297 x 210 mm
//    wxPAPER_A5_ROTATED,         // A5 Rotated 210 x 148 mm
//    wxPAPER_B4_JIS_ROTATED,     // B4 (JIS) Rotated 364 x 257 mm
//    wxPAPER_B5_JIS_ROTATED,     // B5 (JIS) Rotated 257 x 182 mm
//    wxPAPER_JAPANESE_POSTCARD_ROTATED,// Japanese Postcard Rotated 148 x 100 mm
//    wxPAPER_DBL_JAPANESE_POSTCARD_ROTATED,// Double Japanese Postcard Rotated 148 x 200 mm
//    wxPAPER_A6_ROTATED,         // A6 Rotated 148 x 105 mm
//    wxPAPER_JENV_KAKU2_ROTATED, // Japanese Envelope Kaku #2 Rotated
//    wxPAPER_JENV_KAKU3_ROTATED, // Japanese Envelope Kaku #3 Rotated
//    wxPAPER_JENV_CHOU3_ROTATED, // Japanese Envelope Chou #3 Rotated
//    wxPAPER_JENV_CHOU4_ROTATED, // Japanese Envelope Chou #4 Rotated
//    wxPAPER_B6_JIS,             // B6 (JIS) 128 x 182 mm
//    wxPAPER_B6_JIS_ROTATED,     // B6 (JIS) Rotated 182 x 128 mm
//    wxPAPER_12X11,              // 12 x 11 in
//    wxPAPER_JENV_YOU4,          // Japanese Envelope You #4
//    wxPAPER_JENV_YOU4_ROTATED,  // Japanese Envelope You #4 Rotated
//    wxPAPER_P16K,               // PRC 16K 146 x 215 mm
//    wxPAPER_P32K,               // PRC 32K 97 x 151 mm
//    wxPAPER_P32KBIG,            // PRC 32K(Big) 97 x 151 mm
//    wxPAPER_PENV_1,             // PRC Envelope #1 102 x 165 mm
//    wxPAPER_PENV_2,             // PRC Envelope #2 102 x 176 mm
//    wxPAPER_PENV_3,             // PRC Envelope #3 125 x 176 mm
//    wxPAPER_PENV_4,             // PRC Envelope #4 110 x 208 mm
//    wxPAPER_PENV_5,             // PRC Envelope #5 110 x 220 mm
//    wxPAPER_PENV_6,             // PRC Envelope #6 120 x 230 mm
//    wxPAPER_PENV_7,             // PRC Envelope #7 160 x 230 mm
//    wxPAPER_PENV_8,             // PRC Envelope #8 120 x 309 mm
//    wxPAPER_PENV_9,             // PRC Envelope #9 229 x 324 mm
//    wxPAPER_PENV_10,            // PRC Envelope #10 324 x 458 mm
//    wxPAPER_P16K_ROTATED,       // PRC 16K Rotated
//    wxPAPER_P32K_ROTATED,       // PRC 32K Rotated
//    wxPAPER_P32KBIG_ROTATED,    // PRC 32K(Big) Rotated
//    wxPAPER_PENV_1_ROTATED,     // PRC Envelope #1 Rotated 165 x 102 mm
//    wxPAPER_PENV_2_ROTATED,     // PRC Envelope #2 Rotated 176 x 102 mm
//    wxPAPER_PENV_3_ROTATED,     // PRC Envelope #3 Rotated 176 x 125 mm
//    wxPAPER_PENV_4_ROTATED,     // PRC Envelope #4 Rotated 208 x 110 mm
//    wxPAPER_PENV_5_ROTATED,     // PRC Envelope #5 Rotated 220 x 110 mm
//    wxPAPER_PENV_6_ROTATED,     // PRC Envelope #6 Rotated 230 x 120 mm
//    wxPAPER_PENV_7_ROTATED,     // PRC Envelope #7 Rotated 230 x 160 mm
//    wxPAPER_PENV_8_ROTATED,     // PRC Envelope #8 Rotated 309 x 120 mm
//    wxPAPER_PENV_9_ROTATED,     // PRC Envelope #9 Rotated 324 x 229 mm
//    wxPAPER_PENV_10_ROTATED     // PRC Envelope #10 Rotated 458 x 324 m
//} wxPaperSize;
//
///* Printing orientation */
//#ifndef wxPORTRAIT
//#define wxPORTRAIT      1
//#define wxLANDSCAPE     2
//#endif
//
///* Duplex printing modes
// */
//
//enum wxDuplexMode
//{
//    wxDUPLEX_SIMPLEX, // Non-duplex
//    wxDUPLEX_HORIZONTAL,
//    wxDUPLEX_VERTICAL
//};
//
///* Print quality.
// */
//
//#define wxPRINT_QUALITY_HIGH    -1
//#define wxPRINT_QUALITY_MEDIUM  -2
//#define wxPRINT_QUALITY_LOW     -3
//#define wxPRINT_QUALITY_DRAFT   -4
//
//typedef int wxPrintQuality;
//
///* Print mode (currently PostScript only)
// */
//
//enum wxPrintMode
//{
//    wxPRINT_MODE_NONE =    0,
//    wxPRINT_MODE_PREVIEW = 1,   // Preview in external application
//    wxPRINT_MODE_FILE =    2,   // Print to file
//    wxPRINT_MODE_PRINTER = 3,   // Send to printer
//    wxPRINT_MODE_STREAM =  4    //  Send postscript data into a stream
//};
//
//enum wxPrinterError
//{
//    wxPRINTER_NO_ERROR = 0,
//    wxPRINTER_CANCELLED,
//    wxPRINTER_ERROR
//};
//
////  ----------------------------------------------------------------------------
////  UpdateWindowUI flags
////  ----------------------------------------------------------------------------
//
//enum wxUpdateUI
//{
//    wxUPDATE_UI_NONE          = 0x0000,
//    wxUPDATE_UI_RECURSE       = 0x0001,
//    wxUPDATE_UI_FROMIDLE      = 0x0002 /*  Invoked from On(Internal)Idle */
//};
//
//// ----------------------------------------------------------------------------
//// miscellaneous
//// ----------------------------------------------------------------------------
//
//// define this macro if font handling is done using the X font names
//#if (defined(__WXGTK__) && !defined(__WXGTK20__)) || defined(__X__)
//    #define _WX_X_FONTLIKE
//#endif
//
//// macro to specify "All Files" on different platforms
//#if defined(__WXMSW__) || defined(__WXPM__)
//#   define wxALL_FILES_PATTERN   wxT("*.*")
//#   define wxALL_FILES           gettext_noop("All files (*.*)|*.*")
//#else
//#   define wxALL_FILES_PATTERN   wxT("*")
//#   define wxALL_FILES           gettext_noop("All files (*)|*")
//#endif
//
//#if defined(__CYGWIN__) && defined(__WXMSW__)
//#   if wxUSE_STL || defined(wxUSE_STD_STRING)
//         /*
//            NASTY HACK because the gethostname in sys/unistd.h which the gnu
//            stl includes and wx builds with by default clash with each other
//            (windows version 2nd param is int, sys/unistd.h version is unsigned
//            int).
//          */
//#        define gethostname gethostnameHACK
//#        include <unistd.h>
//#        undef gethostname
//#   endif
//#endif
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/gdicmn.h
////** ---------------------------------------------------------------------------- **
//
//enum wxBitmapType
//{
//    wxBITMAP_TYPE_INVALID,          // should be == 0 for compatibility!
//    wxBITMAP_TYPE_BMP,
//    wxBITMAP_TYPE_BMP_RESOURCE,
//    wxBITMAP_TYPE_RESOURCE = wxBITMAP_TYPE_BMP_RESOURCE,
//    wxBITMAP_TYPE_ICO,
//    wxBITMAP_TYPE_ICO_RESOURCE,
//    wxBITMAP_TYPE_CUR,
//    wxBITMAP_TYPE_CUR_RESOURCE,
//    wxBITMAP_TYPE_XBM,
//    wxBITMAP_TYPE_XBM_DATA,
//    wxBITMAP_TYPE_XPM,
//    wxBITMAP_TYPE_XPM_DATA,
//    wxBITMAP_TYPE_TIF,
//    wxBITMAP_TYPE_TIF_RESOURCE,
//    wxBITMAP_TYPE_GIF,
//    wxBITMAP_TYPE_GIF_RESOURCE,
//    wxBITMAP_TYPE_PNG,
//    wxBITMAP_TYPE_PNG_RESOURCE,
//    wxBITMAP_TYPE_JPEG,
//    wxBITMAP_TYPE_JPEG_RESOURCE,
//    wxBITMAP_TYPE_PNM,
//    wxBITMAP_TYPE_PNM_RESOURCE,
//    wxBITMAP_TYPE_PCX,
//    wxBITMAP_TYPE_PCX_RESOURCE,
//    wxBITMAP_TYPE_PICT,
//    wxBITMAP_TYPE_PICT_RESOURCE,
//    wxBITMAP_TYPE_ICON,
//    wxBITMAP_TYPE_ICON_RESOURCE,
//    wxBITMAP_TYPE_ANI,
//    wxBITMAP_TYPE_IFF,
//    wxBITMAP_TYPE_TGA,
//    wxBITMAP_TYPE_MACCURSOR,
//    wxBITMAP_TYPE_MACCURSOR_RESOURCE,
//    wxBITMAP_TYPE_ANY = 50
//};
//
//// Standard cursors
//enum wxStockCursor
//{
//    wxCURSOR_NONE,          // should be 0
//    wxCURSOR_ARROW,
//    wxCURSOR_RIGHT_ARROW,
//    wxCURSOR_BULLSEYE,
//    wxCURSOR_CHAR,
//    wxCURSOR_CROSS,
//    wxCURSOR_HAND,
//    wxCURSOR_IBEAM,
//    wxCURSOR_LEFT_BUTTON,
//    wxCURSOR_MAGNIFIER,
//    wxCURSOR_MIDDLE_BUTTON,
//    wxCURSOR_NO_ENTRY,
//    wxCURSOR_PAINT_BRUSH,
//    wxCURSOR_PENCIL,
//    wxCURSOR_POINT_LEFT,
//    wxCURSOR_POINT_RIGHT,
//    wxCURSOR_QUESTION_ARROW,
//    wxCURSOR_RIGHT_BUTTON,
//    wxCURSOR_SIZENESW,
//    wxCURSOR_SIZENS,
//    wxCURSOR_SIZENWSE,
//    wxCURSOR_SIZEWE,
//    wxCURSOR_SIZING,
//    wxCURSOR_SPRAYCAN,
//    wxCURSOR_WAIT,
//    wxCURSOR_WATCH,
//    wxCURSOR_BLANK,
//    wxCURSOR_DEFAULT, // standard X11 cursor
//    wxCURSOR_COPY_ARROW , // MacOS Theme Plus arrow
//    // Not yet implemented for Windows
//    wxCURSOR_CROSS_REVERSE,
//    wxCURSOR_DOUBLE_ARROW,
//    wxCURSOR_BASED_ARROW_UP,
//    wxCURSOR_BASED_ARROW_DOWN,
//
//    wxCURSOR_ARROWWAIT,
//
//    wxCURSOR_MAX
//};
//
//#ifndef __WXGTK__
//    #define wxCURSOR_DEFAULT wxCURSOR_ARROW
//#endif
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/listbase.h - For ListCtrl
////** ---------------------------------------------------------------------------- **
//
//#define wxLC_VRULES          0x0001
//#define wxLC_HRULES          0x0002
//
//#define wxLC_ICON            0x0004
//#define wxLC_SMALL_ICON      0x0008
//#define wxLC_LIST            0x0010
//#define wxLC_REPORT          0x0020
//
//#define wxLC_ALIGN_TOP       0x0040
//#define wxLC_ALIGN_LEFT      0x0080
//#define wxLC_AUTOARRANGE     0x0100
//#define wxLC_VIRTUAL         0x0200
//#define wxLC_EDIT_LABELS     0x0400
//#define wxLC_NO_HEADER       0x0800
//#define wxLC_NO_SORT_HEADER  0x1000
//#define wxLC_SINGLE_SEL      0x2000
//#define wxLC_SORT_ASCENDING  0x4000
//#define wxLC_SORT_DESCENDING 0x8000
//
//#define wxLC_MASK_TYPE       (wxLC_ICON | wxLC_SMALL_ICON | wxLC_LIST | wxLC_REPORT)
//#define wxLC_MASK_ALIGN      (wxLC_ALIGN_TOP | wxLC_ALIGN_LEFT)
//#define wxLC_MASK_SORT       (wxLC_SORT_ASCENDING | wxLC_SORT_DESCENDING)
//
//// for compatibility only
//#define wxLC_USER_TEXT       wxLC_VIRTUAL
//
//// Mask flags to tell app/GUI what fields of wxListItem are valid
//#define wxLIST_MASK_STATE           0x0001
//#define wxLIST_MASK_TEXT            0x0002
//#define wxLIST_MASK_IMAGE           0x0004
//#define wxLIST_MASK_DATA            0x0008
//#define wxLIST_SET_ITEM             0x0010
//#define wxLIST_MASK_WIDTH           0x0020
//#define wxLIST_MASK_FORMAT          0x0040
//
//// State flags for indicating the state of an item
//#define wxLIST_STATE_DONTCARE       0x0000
//#define wxLIST_STATE_DROPHILITED    0x0001      // MSW only
//#define wxLIST_STATE_FOCUSED        0x0002
//#define wxLIST_STATE_SELECTED       0x0004
//#define wxLIST_STATE_CUT            0x0008      // MSW only
//#define wxLIST_STATE_DISABLED       0x0010      // OS2 only
//#define wxLIST_STATE_FILTERED       0x0020      // OS2 only
//#define wxLIST_STATE_INUSE          0x0040      // OS2 only
//#define wxLIST_STATE_PICKED         0x0080      // OS2 only
//#define wxLIST_STATE_SOURCE         0x0100      // OS2 only
//
//// Hit test flags, used in HitTest
//#define wxLIST_HITTEST_ABOVE            0x0001  // Above the client area.
//#define wxLIST_HITTEST_BELOW            0x0002  // Below the client area.
//#define wxLIST_HITTEST_NOWHERE          0x0004  // In the client area but below the last item.
//#define wxLIST_HITTEST_ONITEMICON       0x0020  // On the bitmap associated with an item.
//#define wxLIST_HITTEST_ONITEMLABEL      0x0080  // On the label (string) associated with an item.
//#define wxLIST_HITTEST_ONITEMRIGHT      0x0100  // In the area to the right of an item.
//#define wxLIST_HITTEST_ONITEMSTATEICON  0x0200  // On the state icon for a tree view item that is in a user-defined state.
//#define wxLIST_HITTEST_TOLEFT           0x0400  // To the left of the client area.
//#define wxLIST_HITTEST_TORIGHT          0x0800  // To the right of the client area.
//
//#define wxLIST_HITTEST_ONITEM (wxLIST_HITTEST_ONITEMICON | wxLIST_HITTEST_ONITEMLABEL | wxLIST_HITTEST_ONITEMSTATEICON)
//
//// Flags for GetNextItem (MSW only except wxLIST_NEXT_ALL)
//enum
//{
//    wxLIST_NEXT_ABOVE,          // Searches for an item above the specified item
//    wxLIST_NEXT_ALL,            // Searches for subsequent item by index
//    wxLIST_NEXT_BELOW,          // Searches for an item below the specified item
//    wxLIST_NEXT_LEFT,           // Searches for an item to the left of the specified item
//    wxLIST_NEXT_RIGHT           // Searches for an item to the right of the specified item
//};
//
//// Alignment flags for Arrange (MSW only except wxLIST_ALIGN_LEFT)
//enum
//{
//    wxLIST_ALIGN_DEFAULT,
//    wxLIST_ALIGN_LEFT,
//    wxLIST_ALIGN_TOP,
//    wxLIST_ALIGN_SNAP_TO_GRID
//};
//
//// Column format (MSW only except wxLIST_FORMAT_LEFT)
//enum wxListColumnFormat
//{
//    wxLIST_FORMAT_LEFT,
//    wxLIST_FORMAT_RIGHT,
//    wxLIST_FORMAT_CENTRE,
//    wxLIST_FORMAT_CENTER = wxLIST_FORMAT_CENTRE
//};
//
//// Autosize values for SetColumnWidth
//enum
//{
//    wxLIST_AUTOSIZE = -1,
//    wxLIST_AUTOSIZE_USEHEADER = -2      // partly supported by generic version
//};
//
//// Flag values for GetItemRect
//enum
//{
//    wxLIST_RECT_BOUNDS,
//    wxLIST_RECT_ICON,
//    wxLIST_RECT_LABEL
//};
//
//// Flag values for FindItem (MSW only)
//enum
//{
//    wxLIST_FIND_UP,
//    wxLIST_FIND_DOWN,
//    wxLIST_FIND_LEFT,
//    wxLIST_FIND_RIGHT
//};
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/button.h
////** ---------------------------------------------------------------------------- **
//
//
//// These flags affect label alignment
//#define wxBU_LEFT            0x0040
//#define wxBU_TOP             0x0080
//#define wxBU_RIGHT           0x0100
//#define wxBU_BOTTOM          0x0200
//#define wxBU_ALIGN_MASK      ( wxBU_LEFT | wxBU_TOP | wxBU_RIGHT | wxBU_BOTTOM )
//
//
//// ----------------------------------------------------------------------------
//// wxButton specific flags
//// ----------------------------------------------------------------------------
//
//// These two flags are obsolete
//#define wxBU_NOAUTODRAW      0x0000
//#define wxBU_AUTODRAW        0x0004
//
//// by default, the buttons will be created with some (system dependent)
//// minimal size to make them look nicer, giving this style will make them as
//// small as possible
//#define wxBU_EXACTFIT        0x0001
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/treebase.h
////** ---------------------------------------------------------------------------- **
//
//// enum for different images associated with a treectrl item
//enum wxTreeItemIcon
//{
//    wxTreeItemIcon_Normal,              // not selected, not expanded
//    wxTreeItemIcon_Selected,            //     selected, not expanded
//    wxTreeItemIcon_Expanded,            // not selected,     expanded
//    wxTreeItemIcon_SelectedExpanded,    //     selected,     expanded
//    wxTreeItemIcon_Max
//};
//
//// tree constants
//#define wxTR_NO_BUTTONS              0x0000     // for convenience
//#define wxTR_HAS_BUTTONS             0x0001     // draw collapsed/expanded btns
//#define wxTR_NO_LINES                0x0004     // don't draw lines at all
//#define wxTR_LINES_AT_ROOT           0x0008     // connect top-level nodes
//#define wxTR_TWIST_BUTTONS           0x0010     // still used by wxTreeListCtrl
//#define wxTR_SINGLE                  0x0000     // for convenience
//#define wxTR_MULTIPLE                0x0020     // can select multiple items
//#define wxTR_EXTENDED                0x0040     // TODO: allow extended selection
//#define wxTR_HAS_VARIABLE_ROW_HEIGHT 0x0080     // what it says
//#define wxTR_EDIT_LABELS             0x0200     // can edit item labels
//#define wxTR_ROW_LINES               0x0400     // put border around items
//#define wxTR_HIDE_ROOT               0x0800     // don't display root node
//#define wxTR_FULL_ROW_HIGHLIGHT      0x2000     // highlight full horz space
//#ifdef __WXGTK20__
//#define wxTR_DEFAULT_STYLE           (wxTR_HAS_BUTTONS | wxTR_NO_LINES)
//#else
//#define wxTR_DEFAULT_STYLE           (wxTR_HAS_BUTTONS | wxTR_LINES_AT_ROOT)
//#endif
//
//// deprecated, don't use
//#define wxTR_MAC_BUTTONS             0
//#define wxTR_AQUA_BUTTONS            0
//
//%constant const int TREE_HITTEST_ABOVE            = 0x0001;
//%constant const int TREE_HITTEST_BELOW            = 0x0002;
//%constant const int TREE_HITTEST_NOWHERE          = 0x0004;
//    // on the button associated with an item.
//%constant const int TREE_HITTEST_ONITEMBUTTON     = 0x0008;
//    // on the bitmap associated with an item.
//%constant const int TREE_HITTEST_ONITEMICON       = 0x0010;
//    // on the indent associated with an item.
//%constant const int TREE_HITTEST_ONITEMINDENT     = 0x0020;
//    // on the label (string) associated with an item.
//%constant const int TREE_HITTEST_ONITEMLABEL      = 0x0040;
//    // on the right of the label associated with an item.
//%constant const int TREE_HITTEST_ONITEMRIGHT      = 0x0080;
//    // on the label (string) associated with an item.
//%constant const int TREE_HITTEST_ONITEMSTATEICON  = 0x0100;
//    // on the left of the wxTreeCtrl.
//%constant const int TREE_HITTEST_TOLEFT           = 0x0200;
//    // on the right of the wxTreeCtrl.
//%constant const int TREE_HITTEST_TORIGHT          = 0x0400;
//    // on the upper part (first half) of the item.
//%constant const int TREE_HITTEST_ONITEMUPPERPART  = 0x0800;
//    // on the lower part (second half) of the item.
//%constant const int TREE_HITTEST_ONITEMLOWERPART  = 0x1000;
//
//    // anywhere on the item
//%constant const int TREE_HITTEST_ONITEM  = 0x0010 | 0x0040;//TREE_HITTEST_ONITEMICON | TREE_HITTEST_ONITEMLABEL;
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/calctrl.h
////** ---------------------------------------------------------------------------- **
//
//// calendar constants
//enum
//{
//    // show Sunday as the first day of the week (default)
//    wxCAL_SUNDAY_FIRST               = 0x0000,
//
//    // show Monder as the first day of the week
//    wxCAL_MONDAY_FIRST               = 0x0001,
//
//    // highlight holidays
//    wxCAL_SHOW_HOLIDAYS              = 0x0002,
//
//    // disable the year change control, show only the month change one
//    wxCAL_NO_YEAR_CHANGE             = 0x0004,
//
//    // don't allow changing neither month nor year (implies
//    // wxCAL_NO_YEAR_CHANGE)
//    wxCAL_NO_MONTH_CHANGE            = 0x000c,
//
//    // use MS-style month-selection instead of combo-spin combination
//    wxCAL_SEQUENTIAL_MONTH_SELECTION = 0x0010,
//
//    // show the neighbouring weeks in the previous and next month
//    wxCAL_SHOW_SURROUNDING_WEEKS     = 0x0020
//};
//
//enum wxCalendarHitTestResult
//{
//    wxCAL_HITTEST_NOWHERE,      // outside of anything
//    wxCAL_HITTEST_HEADER,       // on the header (weekdays)
//    wxCAL_HITTEST_DAY,          // on a day in the calendar
//    wxCAL_HITTEST_INCMONTH,
//    wxCAL_HITTEST_DECMONTH,
//    wxCAL_HITTEST_SURROUNDING_WEEK
//};
//
//// border types for a date
//enum wxCalendarDateBorder
//{
//    wxCAL_BORDER_NONE,          // no border (default)
//    wxCAL_BORDER_SQUARE,        // a rectangular border
//    wxCAL_BORDER_ROUND          // a round border
//};
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/toplevel.h
////** ---------------------------------------------------------------------------- **
//
///*
// * wxFrame/wxDialog style flags
// */
//#define wxSTAY_ON_TOP           0x8000
//#define wxICONIZE               0x4000
//#define wxMINIMIZE              wxICONIZE
//#define wxMAXIMIZE              0x2000
//#define wxCLOSE_BOX             0x1000
//                                        // free flag value: 0x1000
//#define wxSYSTEM_MENU           0x0800
//#define wxMINIMIZE_BOX          0x0400
//#define wxMAXIMIZE_BOX          0x0200
//#define wxTINY_CAPTION_HORIZ    0x0100
//#define wxTINY_CAPTION_VERT     0x0080
//#define wxRESIZE_BORDER         0x0040
//
//// deprecated versions defined for compatibility reasons
//#define wxRESIZE_BOX            wxMAXIMIZE_BOX
//#define wxTHICK_FRAME           wxRESIZE_BORDER
//
//// obsolete styles, unused any more
//#define wxDIALOG_MODAL          0
//#define wxDIALOG_MODELESS       0
//#define wxNO_3D                 0
//#define wxUSER_COLOURS          0
//
//// default style
////
//// under Windows CE (at least when compiling with eVC 4) we should create
//// top level windows without any styles at all for them to appear
//// "correctly", i.e. as full screen windows with a "hide" button (same as
//// "close" but round instead of squared and just hides the applications
//// instead of closing it) in the title bar
//#if defined(__WXWINCE__)
//    #if defined(__SMARTPHONE__)
//        #define wxDEFAULT_FRAME_STYLE (wxMAXIMIZE)
//    #elif defined(__WINCE_STANDARDSDK__)
//        #define wxDEFAULT_FRAME_STYLE (wxMAXIMIZE|wxCLOSE_BOX)
//    #else
//        #define wxDEFAULT_FRAME_STYLE (wxNO_BORDER)
//    #endif
//#else // !__WXWINCE__
//    #define wxDEFAULT_FRAME_STYLE \
//            (wxSYSTEM_MENU | \
//             wxRESIZE_BORDER | \
//             wxMINIMIZE_BOX | \
//             wxMAXIMIZE_BOX | \
//             wxCLOSE_BOX | \
//             wxCAPTION | \
//             wxCLIP_CHILDREN)
//#endif
//
//// Dialogs are created in a special way
//#define wxTOPLEVEL_EX_DIALOG        0x00000008
//
//// Styles for ShowFullScreen
//// (note that wxTopLevelWindow only handles wxFULLSCREEN_NOBORDER and
////  wxFULLSCREEN_NOCAPTION; the rest is handled by wxTopLevelWindow)
//enum
//{
//    wxFULLSCREEN_NOMENUBAR   = 0x0001,
//    wxFULLSCREEN_NOTOOLBAR   = 0x0002,
//    wxFULLSCREEN_NOSTATUSBAR = 0x0004,
//    wxFULLSCREEN_NOBORDER    = 0x0008,
//    wxFULLSCREEN_NOCAPTION   = 0x0010,
//
//    wxFULLSCREEN_ALL         = wxFULLSCREEN_NOMENUBAR | wxFULLSCREEN_NOTOOLBAR |
//                               wxFULLSCREEN_NOSTATUSBAR | wxFULLSCREEN_NOBORDER |
//                               wxFULLSCREEN_NOCAPTION
//};
//
//// Styles for RequestUserAttention
//enum
//{
//    wxUSER_ATTENTION_INFO = 1,
//    wxUSER_ATTENTION_ERROR = 2
//};
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/frame.h
////** ---------------------------------------------------------------------------- **
//
//// wxFrame-specific (i.e. not for wxDialog) styles
//#define wxFRAME_NO_TASKBAR      0x0002  // No taskbar button (MSW only)
//#define wxFRAME_TOOL_WINDOW     0x0004  // No taskbar button, no system menu
//#define wxFRAME_FLOAT_ON_PARENT 0x0008  // Always above its parent
//#define wxFRAME_SHAPED          0x0010  // Create a window that is able to be shaped
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/dialog.h
////** ---------------------------------------------------------------------------- **
//
//#define wxDIALOG_NO_PARENT      0x0001  // Don't make owned by apps top window
//
//#ifdef __WXWINCE__
//#define wxDEFAULT_DIALOG_STYLE  (wxCAPTION | wxMAXIMIZE | wxCLOSE_BOX | wxNO_BORDER)
//#else
//#define wxDEFAULT_DIALOG_STYLE  (wxCAPTION | wxSYSTEM_MENU | wxCLOSE_BOX)
//#endif
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/gauge.h
////** ---------------------------------------------------------------------------- **
//
//#define wxGA_HORIZONTAL      wxHORIZONTAL
//#define wxGA_VERTICAL        wxVERTICAL
//
//// Win32 only, is default (and only) on some other platforms
//#define wxGA_SMOOTH          0x0020
//
//// obsolete style
//#define wxGA_PROGRESSBAR     0
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/slider.h
////** ---------------------------------------------------------------------------- **
//
///*
// * wxSlider flags
// */
//#define wxSL_HORIZONTAL      wxHORIZONTAL
//#define wxSL_VERTICAL        wxVERTICAL
//
//#define wxSL_TICKS           0x0010
//#define wxSL_AUTOTICKS       wxSL_TICKS // we don't support manual ticks
//#define wxSL_LABELS          0x0020
//#define wxSL_LEFT            0x0040
//#define wxSL_TOP             0x0080
//#define wxSL_RIGHT           0x0100
//#define wxSL_BOTTOM          0x0200
//#define wxSL_BOTH            0x0400
//#define wxSL_SELRANGE        0x0800
//#define wxSL_INVERSE         0x1000
//
//// obsolete
//#define wxSL_NOTIFY_DRAG     0x0000
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/splitter.h
////** ---------------------------------------------------------------------------- **
//
///*
// * wxSplitterWindow flags
// */
//#define wxSP_NOBORDER         0x0000
//#define wxSP_NOSASH           0x0010
//#define wxSP_PERMIT_UNSPLIT   0x0040
//#define wxSP_LIVE_UPDATE      0x0080
//#define wxSP_3DSASH           0x0100
//#define wxSP_3DBORDER         0x0200
//#define wxSP_NO_XP_THEME      0x0400
//#define wxSP_BORDER           wxSP_3DBORDER
//#define wxSP_3D               (wxSP_3DBORDER | wxSP_3DSASH)
//
//// obsolete styles, don't do anything
//#define wxSP_SASH_AQUA        0
//#define wxSP_FULLSASH         0
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/fdrepdlg.h
////** ---------------------------------------------------------------------------- **
//
//// flags used by wxFindDialogEvent::GetFlags()
//enum wxFindReplaceFlags
//{
//    // downward search/replace selected (otherwise - upwards)
//    wxFR_DOWN       = 1,
//
//    // whole word search/replace selected
//    wxFR_WHOLEWORD  = 2,
//
//    // case sensitive search/replace selected (otherwise - case insensitive)
//    wxFR_MATCHCASE  = 4
//};
//
//enum wxFindReplaceDialogStyles
//{
//    // replace dialog (otherwise find dialog)
//    wxFR_REPLACEDIALOG = 1,
//
//    // don't allow changing the search direction
//    wxFR_NOUPDOWN      = 2,
//
//    // don't allow case sensitive searching
//    wxFR_NOMATCHCASE   = 4,
//
//    // don't allow whole word searching
//    wxFR_NOWHOLEWORD   = 8
//};
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/valtext.h
////** ---------------------------------------------------------------------------- **
//
//#define wxFILTER_NONE           0x0000
//#define wxFILTER_ASCII          0x0001
//#define wxFILTER_ALPHA          0x0002
//#define wxFILTER_ALPHANUMERIC   0x0004
//#define wxFILTER_NUMERIC        0x0008
//#define wxFILTER_INCLUDE_LIST   0x0010
//#define wxFILTER_EXCLUDE_LIST   0x0020
//#define wxFILTER_INCLUDE_CHAR_LIST 0x0040
//#define wxFILTER_EXCLUDE_CHAR_LIST 0x0080
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/sashwin.h
////** ---------------------------------------------------------------------------- **
//
//enum wxSashDragStatus
//{
//    wxSASH_STATUS_OK,
//    wxSASH_STATUS_OUT_OF_RANGE
//};
//
////** ---------------------------------------------------------------------------- **
////   Start constants from wx/timer.h
////** ---------------------------------------------------------------------------- **
//
//// generate notifications periodically until the timer is stopped (default)
//%constant bool TIMER_CONTINUOUS = false;
//
//// only send the notification once and then stop the timer
//%constant bool TIMER_ONE_SHOT = true;

//** ---------------------------------------------------------------------------- **
//   Start SWIG fixes for constants
//** ---------------------------------------------------------------------------- **

%constant const wxValidator DEFAULT_VALIDATOR = wxDefaultValidator;


// 'Null' objects
%constant wxAnimation const NULL_ANIMATION = wxNullAnimation;
%constant wxCursor const    NULL_CURSOR = wxNullCursor;
%constant wxPen const       NULL_PEN = wxNullPen;
%constant wxBrush const     NULL_BRUSH = wxNullBrush;
%constant wxPalette const   NULL_PALETTE = wxNullPalette;

//    // Pen styles
///*
//%constant int SOLID       =    wxSOLID;
//%constant int DOT         =    wxDOT;
//%constant int LONG_DASH   =    wxLONG_DASH;
//%constant int SHORT_DASH  =    wxSHORT_DASH;
//%constant int DOT_DASH    =    wxDOT_DASH;
//%constant int USER_DASH   =    wxUSER_DASH;
//%constant int TRANSPARENT =    wxTRANSPARENT;
//*/

// Hack:  SWIG Ruby doesn't handle unicode constants, so we redeclare as ASCII
#define wxART_MAKE_CLIENT_ID(id)           #id "_C"
#define wxART_MAKE_ART_ID(id)              #id

%constant const int LAYOUT_UNCONSTRAINED = wxUnconstrained;
%constant const int LAYOUT_AS_IS = wxAsIs;
%constant const int LAYOUT_PERCENT_OF = wxPercentOf;
%constant const int LAYOUT_ABOVE = wxAbove;
%constant const int LAYOUT_BELOW = wxBelow;
%constant const int LAYOUT_LEFT_OF = wxLeftOf;
%constant const int LAYOUT_RIGHT_OF = wxRightOf;
%constant const int LAYOUT_SAME_AS = wxSameAs;
%constant const int LAYOUT_ABSOLUTE = wxAbsolute;
//
//enum wxLayoutAlignment
//{
//	wxLAYOUT_LEFT,
//	wxLAYOUT_TOP,
//	wxLAYOUT_RIGHT,
//	wxLAYOUT_BOTTOM
//};
//
//%constant const int LAYOUT_WIDTH =wxWidth;
//%constant const int LAYOUT_HEIGHT =wxHeight;
//
//enum wxLayoutOrientation
//{
//    wxLAYOUT_HORIZONTAL,
//    wxLAYOUT_VERTICAL
//};
//
//%constant const int LAYOUT_CENTRE =wxCentre;
//%constant const int LAYOUT_CENTER =wxCenter;
//%constant const int LAYOUT_CENTRE_X =wxCentreX;
//%constant const int LAYOUT_CENTRE_Y =wxCentreY;
//
//%constant const int NOT_FOUND = -1;
//
//%constant const char * wxEmptyString = "";
//
//%constant const int TREE_ITEM_ICON_NORMAL = wxTreeItemIcon_Normal;
//%constant const int TREE_ITEM_ICON_SELECTED = wxTreeItemIcon_Selected;
//%constant const int TREE_ITEM_ICON_EXPANDED = wxTreeItemIcon_Expanded;
//%constant const int TREE_ITEM_ICON_SELECTED_EXPANDED = wxTreeItemIcon_SelectedExpanded;
//%constant const int TREE_ITEM_ICON_MAX = wxTreeItemIcon_Max;
//
//// Double buffering helper
//
//// Assumes the buffer bitmap covers the entire scrolled window,
//// and prepares the window DC accordingly
////#define wxBUFFER_VIRTUAL_AREA       0x01
//
//// Assumes the buffer bitmap only covers the client area;
//// does not prepare the window DC
////#define wxBUFFER_CLIENT_AREA        0x02
//
