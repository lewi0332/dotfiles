import plotly.io as pio

from .rev import plotly_rev
from .light import plotly_light

__all__ = ['plotly_rev', 'plotly_light', 'use_rev', 'use_light', 'apply_default_renderer_config']

DEFAULT_SHOW_CONFIG = {
    'modeBarButtonsToAdd': [
        'drawline',
        'drawopenpath',
        'drawclosedpath',
        'drawcircle',
        'drawrect',
        'eraseshape',
    ]
}


def apply_default_renderer_config(renderers=None):
    """Apply default modebar config to selected Plotly renderers."""
    target_renderers = renderers or ['notebook', 'notebook_connected', 'vscode', 'browser']
    available_renderers = set(pio.renderers)
    for renderer_name in target_renderers:
        if renderer_name not in available_renderers:
            continue
        renderer = pio.renderers[renderer_name]
        renderer.config = {**(renderer.config or {}), **DEFAULT_SHOW_CONFIG}


def use_rev():
    """Set the dark color palette as the default Plotly template."""
    pio.templates.default = plotly_rev
    apply_default_renderer_config()


def use_light():
    """Set the light/teal color palette as the default Plotly template."""
    pio.templates.default = plotly_light
    apply_default_renderer_config()
