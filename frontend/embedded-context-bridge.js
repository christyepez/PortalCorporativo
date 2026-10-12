(function () {
  try {
    if (window.parent && window.parent !== window && window.parent.__PORTAL_SHELL_CONTEXT__) {
      window.__PORTAL_SHELL_CONTEXT__ = JSON.parse(JSON.stringify(window.parent.__PORTAL_SHELL_CONTEXT__));
    }
  } catch (error) {
    console.warn('Portal embedded context bridge unavailable.', error);
  }
})();