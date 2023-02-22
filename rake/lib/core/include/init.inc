
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
    if (! wxGetInstance())
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
    actctx.lpResourceName = MAKEINTRESOURCE(2);
    actctx.hModule = wxGetInstance();
    actctx.dwFlags = ACTCTX_FLAG_HMODULE_VALID | ACTCTX_FLAG_RESOURCE_NAME_VALID;

    h = CreateActCtx(&actctx);
    if (h == INVALID_HANDLE_VALUE) {
        wxLogLastError(wxT("CreateActCtx"));
        return;
    }

    if (! ActivateActCtx(h, &cookie))
        wxLogLastError(wxT("ActivateActCtx"));
}

#endif
