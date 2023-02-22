
#ifdef __WXMSW__

extern "C"
{
    WXDLLIMPEXP_BASE HINSTANCE wxGetInstance();
}

WXDLLIMPEXP_BASE void wxSetInstance(HINSTANCE hInst);

//----------------------------------------------------------------------
// This gets run when the DLL is loaded.  We just need to save the
// instance handle.
//----------------------------------------------------------------------

extern "C"
BOOL WINAPI DllMain(
    HINSTANCE   hinstDLL,    // handle to DLL module
    DWORD       fdwReason,   // reason for calling function
    LPVOID      lpvReserved)
{
    // If wxRuby is embedded in another (wxWidgets) app then
    // the instance may already have been set.
    if (fdwReason==DLL_PROCESS_ATTACH && !wxGetInstance())
        wxSetInstance(hinstDLL);

    return TRUE;
}

// Adapted from wxPython
static void wxRuby_SetActivationContext()
{

    OSVERSIONINFO info;
    memset(&info, 0, sizeof(OSVERSIONINFO));
    info.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
    GetVersionEx(&info);
    if (info.dwMajorVersion < 5)
        return;

    ULONG_PTR cookie = 0;
    HANDLE h;
    ACTCTX actctx;
    TCHAR modulename[MAX_PATH];

    GetModuleFileName(wxGetInstance(), modulename, MAX_PATH);
    memset(&actctx, 0, sizeof(ACTCTX));
    actctx.cbSize = sizeof(actctx);
    actctx.lpSource = modulename;
#ifdef ISOLATION_AWARE_ENABLED    
    actctx.lpResourceName = MAKEINTRESOURCE(2);
#else    
    actctx.lpResourceName = MAKEINTRESOURCE(1);
#endif
    actctx.hModule = wxGetInstance();
    actctx.dwFlags = ACTCTX_FLAG_HMODULE_VALID | ACTCTX_FLAG_RESOURCE_NAME_VALID;

    h = CreateActCtx(&actctx);
    if (h == INVALID_HANDLE_VALUE) 
    {
        LPTSTR lpMsgBuf;
        DWORD dw = GetLastError(); 

        FormatMessage(
            FORMAT_MESSAGE_ALLOCATE_BUFFER | 
            FORMAT_MESSAGE_FROM_SYSTEM |
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            dw,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            (LPTSTR) &lpMsgBuf,
            0, NULL );
        ::fprintf(stderr, "Error in CreateActCtx : %s\n", lpMsgBuf);
        return;
    }

    if (! ActivateActCtx(h, &cookie))
    {
        LPTSTR lpMsgBuf;
        DWORD dw = GetLastError(); 

        FormatMessage(
            FORMAT_MESSAGE_ALLOCATE_BUFFER | 
            FORMAT_MESSAGE_FROM_SYSTEM |
            FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL,
            dw,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            (LPTSTR) &lpMsgBuf,
            0, NULL );
        ::fprintf(stderr, "Error in ActivateActCtx : %s\n", lpMsgBuf);
    }
}

#endif
