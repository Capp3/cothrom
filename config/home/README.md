# Dashy Configuration

This directory contains your Dashy dashboard configuration with JSON Schema validation support.

## Files

- `conf.yml` - Your main Dashy configuration file
- `dashy-conf.schema.json` - JSON Schema for validation and IntelliSense

## Features

The JSON Schema provides:

1. **IntelliSense** - Auto-completion for all Dashy config options in VS Code and compatible editors
2. **Validation** - Real-time error checking for invalid configurations
3. **Documentation** - Inline help text for all properties (hover over any property to see documentation)
4. **Type Safety** - Catch configuration errors before deployment

## Usage

The schema is automatically applied to `conf.yml` via the YAML language server directive at the top of the file:

```yaml
# yaml-language-server: $schema=./dashy-conf.schema.json
```

### In VS Code

1. Install the "YAML" extension by Red Hat (if not already installed)
2. Open `conf.yml` - IntelliSense should work automatically
3. Hover over any property to see documentation
4. Press `Ctrl+Space` to trigger auto-completion

### Global Configuration (Optional)

To apply the schema to all Dashy config files automatically, add to your VS Code `settings.json`:

```json
{
  "yaml.schemas": {
    "./config/home/dashy-conf.schema.json": ["**/conf.yml", "**/dashy*.yml"]
  }
}
```

## Schema Coverage

The schema includes comprehensive support for:

### Top-Level Configuration
- `pageInfo` - Dashboard title, description, logo, footer, navigation links
- `appConfig` - Application settings, themes, authentication, features
- `sections` - Content sections with items and widgets
- `pages` - Multi-page dashboard support

### App Config Options
- **Basic**: language, themes, layout, icon size, status checks
- **Advanced**: custom CSS, external stylesheets, favicon APIs, Font Awesome
- **Features**: web search, authentication (simple, Keycloak, OIDC, Header Auth), component visibility
- **Flags**: multitasking, service worker, error reporting, configuration protection

### Sections & Items
- **Items**: title, URL, description, icons, status checks, hotkeys, colors, display rules
- **Widgets**: 40+ widget types with flexible options
- **Display Data**: sorting, collapsing, layout, user visibility controls

### Validation Features
- Enum validation for fixed-value options (themes, opening methods, etc.)
- Pattern matching for colors, ISO codes, URLs
- Min/max constraints for numeric values
- Conditional requirements (e.g., customSearchEngine required when searchEngine is "custom")
- Required field validation

## Widget Types Supported

The schema recognizes 40+ widget types including:
- System monitoring (Glances, NetData, System Info)
- Network (Pi-hole, AdGuard, Mullvad, Gluetun)
- Crypto (Watch List, Price Charts, Wallet Balance, Gas Prices)
- News & Weather (Headlines, Weather, Weather Forecast)
- Finance (Stock Charts, Exchange Rates)
- Services (Uptime Kuma, Stat Ping, Health Checks)
- Productivity (Clock, Calendar, To-Do, Code Stats, RescueTime)
- Media & Gaming (Minecraft Status, Sports Scores, TFL Status)
- And many more...

## Examples

### Adding Status Checks
```yaml
appConfig:
  statusCheck: true
  statusCheckInterval: 300  # Check every 5 minutes
```

### Customizing Item Display
```yaml
items:
  - title: GitHub
    url: https://github.com
    icon: fab fa-github
    target: newtab
    hotkey: 1
    color: "#ffffff"
    backgroundColor: "#24292e"
```

### Adding a Widget
```yaml
sections:
  - name: System Monitor
    widgets:
      - type: glances
        options:
          hostname: http://192.168.1.100:61208
        updateInterval: 10
        useProxy: false
```

## Resources

- [Official Dashy Documentation](https://dashy.to/docs/configuring/)
- [Widget Documentation](https://dashy.to/docs/widgets/)
- [Icons Documentation](https://dashy.to/docs/icons/)
- [Theming Documentation](https://dashy.to/docs/theming/)
- [Authentication Documentation](https://dashy.to/docs/authentication/)

## Troubleshooting

### IntelliSense not working?
1. Ensure the YAML extension is installed
2. Check that the schema path in the yaml-language-server directive is correct
3. Reload VS Code window (`Ctrl+Shift+P` → "Reload Window")

### Schema validation errors?
- Check the error message tooltip for details
- Ensure all required fields are present
- Verify enum values match exactly (case-sensitive)
- Check that URLs are properly formatted

### Need more help?
- Hover over properties to see documentation
- Check the [Dashy troubleshooting guide](https://dashy.to/docs/troubleshooting/)
- Review example configs in the [Dashy repository](https://github.com/Lissy93/dashy)
