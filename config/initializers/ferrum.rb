# Ferrum configuration for PDF generation
# Ferrum will automatically find Chrome/Chromium in standard locations

# Default browser options that will be used for certificate generation
FERRUM_OPTIONS = {
  headless: true,
  window_size: [ 1200, 800 ],
  browser_options: {
    'no-sandbox': nil,
    'disable-dev-shm-usage': nil,
    'disable-gpu': nil,
    'disable-web-security': nil,
    'allow-running-insecure-content': nil,
    'disable-background-timer-throttling': nil,
    'disable-backgrounding-occluded-windows': nil,
    'disable-renderer-backgrounding': nil,
    'disable-images': false,
    'disable-javascript': false,
    'disable-extensions': nil,
    'disable-plugins': nil
  }
}.freeze
