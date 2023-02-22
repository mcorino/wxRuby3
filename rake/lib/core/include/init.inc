
#ifdef __WXMSW__

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

// "Borrowed" from wxPython
static void wxRuby_SetActivationContext()
{

    OSVERSIONINFO info;
    wxZeroMemory(info);
    info.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
    GetVersionEx(&info);
    if (info.dwMajorVersion < 5)
        return 0;

    ULONG_PTR cookie = 0;
    HANDLE h;
    ACTCTX actctx;
    TCHAR modulename[MAX_PATH];

    GetModuleFileName(wxGetInstance(), modulename, MAX_PATH);
    wxZeroMemory(actctx);
    actctx.cbSize = sizeof(actctx);
    actctx.lpSource = modulename;
    actctx.lpResourceName = MAKEINTRESOURCE(2);
    actctx.hModule = wxGetInstance();
    actctx.dwFlags = ACTCTX_FLAG_HMODULE_VALID | ACTCTX_FLAG_RESOURCE_NAME_VALID;

    h = CreateActCtx(&actctx);
    if (h == INVALID_HANDLE_VALUE) {
        wxLogLastError(wxT("CreateActCtx"));
        return 0;
    }

    if (! ActivateActCtx(h, &cookie))
        wxLogLastError(wxT("ActivateActCtx"));
}

#endif
