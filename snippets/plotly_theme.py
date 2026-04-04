import plotly.graph_objects as go
import plotly.io as pio

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

plotly_light = go.layout.Template(layout=go.Layout({
    'annotationdefaults': {
        'arrowcolor': '#f2f5fa',
        'arrowhead': 0,
        'arrowwidth': 1
    },
    'coloraxis': {
        'colorbar': {
            'outlinewidth': 0,
            'ticks': '',
        }
    },
    'colorscale': {
        'diverging': [[0, '#8e0152'], [0.1, '#c51b7d'], [0.2, '#de77ae'], [0.3, '#f1b6da'], [0.4, '#fde0ef'],
                      [0.5, '#f7f7f7'], [0.6, '#e6f5d0'], [0.7, '#b8e186'], [0.8, '#7fbc41'], [0.9, '#4d9221'],
                      [1, '#276419']],
        'sequential': [[0.0, '#0d0887'], [0.1111111111111111, '#46039f'], [0.2222222222222222, '#7201a8'],
                       [0.3333333333333333, '#9c179e'], [0.4444444444444444, '#bd3786'],
                       [0.5555555555555556, '#d8576b'], [0.6666666666666666, '#ed7953'],
                       [0.7777777777777778, '#fb9f3a'], [0.8888888888888888, '#fdca26'], [1.0, '#f0f921']],
        'sequentialminus': [[0.0, '#0d0887'], [0.1111111111111111, '#46039f'], [0.2222222222222222, '#7201a8'],
                            [0.3333333333333333, '#9c179e'], [0.4444444444444444, '#bd3786'],
                            [0.5555555555555556, '#d8576b'], [0.6666666666666666, '#ed7953'],
                            [0.7777777777777778, '#fb9f3a'], [0.8888888888888888, '#fdca26'], [1.0, '#f0f921']]
    },
    'colorway': [
        '#E55800', '#424242', '#0542D0', '#E5A101', '#E6CB05', '#12B6A9', '#14006C'
    ],
    'font': {
        'color': '#2a3f5f',
        'family': 'plain, arial'
    },
    'geo': {
        'bgcolor': 'black',
        'lakecolor': 'white',
        'landcolor': 'white',
        'showlakes': True,
        'showland': True,
        'subunitcolor': '#506784'
    },
    'hoverlabel': {
        'align': 'left'
    },
    'hovermode':
    'closest',
    'mapbox': {
        'style': 'light'
    },
    'paper_bgcolor':
    'white',
    'plot_bgcolor':
    'white',
    'polar': {
        'angularaxis': {
            'gridcolor': '#506784',
            'linecolor': '#506784',
            'ticks': ''
        },
        'bgcolor': 'white',
        'radialaxis': {
            'gridcolor': '#506784',
            'linecolor': '#506784',
            'ticks': ''
        }
    },
    'scene': {
        'xaxis': {
            'backgroundcolor': 'white',
            'gridcolor': '#506784',
            'gridwidth': 2,
            'linecolor': '#506784',
            'showbackground': True,
            'ticks': '',
            'zerolinecolor': '#C8D4E3'
        },
        'yaxis': {
            'backgroundcolor': 'white',
            'gridcolor': '#506784',
            'gridwidth': 2,
            'linecolor': '#506784',
            'showbackground': True,
            'ticks': '',
            'zerolinecolor': '#C8D4E3'
        },
        'zaxis': {
            'backgroundcolor': 'rgb(17,17,17)',
            'gridcolor': '#506784',
            'gridwidth': 2,
            'linecolor': '#506784',
            'showbackground': True,
            'ticks': '',
            'zerolinecolor': '#C8D4E3'
        }
    },
    'shapedefaults': {
        'line': {
            'color': '#f2f5fa'
        }
    },
    'sliderdefaults': {
        'bgcolor': '#C8D4E3',
        'bordercolor': 'rgb(17,17,17)',
        'borderwidth': 1,
        'tickwidth': 0
    },
    'ternary': {
        'aaxis': {
            'gridcolor': '#506784',
            'linecolor': '#506784',
            'ticks': ''
        },
        'baxis': {
            'gridcolor': '#506784',
            'linecolor': '#506784',
            'ticks': ''
        },
        'bgcolor': 'rgb(17,17,17)',
        'caxis': {
            'gridcolor': '#506784',
            'linecolor': '#506784',
            'ticks': ''
        }
    },
    'title': {
        'x': 0.05,
        'font': {
            #         'size': 24
        }
    },
    'updatemenudefaults': {
        'bgcolor': '#506784',
        'borderwidth': 0
    },
    'xaxis': {
        'automargin': True,
        'gridcolor': '#DFE8F3',
        'linecolor': '#A2B1C6',
        'ticks': '',
        'tickfont': {
            'family': 'Interstate Mono, Courier',
            #                            'size': 10,
            'color': '#2a3f5f'
        },
        'title': {
            'font': {
                #                       'size': 18,
                'family': 'inter, arial'
            }
        },
        'zerolinecolor': '#DFE8F3',
        'zerolinewidth': 2
    },
    'yaxis': {
        'automargin': True,
        'gridcolor': '#DFE8F3',
        'linecolor': '#A2B1C6',
        'ticks': '',
        'tickfont': {
            'family': 'Interstate Mono, Courier',
            #                            'size': 10,
            'color': '#2a3f5f'
        },
        'title': {
            'font': {
                #                       'size': 18,
                'family': 'plain, arial'
            }
        },
        'zerolinecolor': '#DFE8F3',
        'zerolinewidth': 2
    },
    'images': [{
        "source": 'https://product-derrick.s3.amazonaws.com/logoWhite.png',
        "xref": "paper",
        "yref": "paper",
        "x": .15,
        "y": .75,
        "sizex": .7,
        "sizey": .7,
        "opacity": 0.05,
        "layer": "below"
    }]
}))

pio.templates.default = plotly_light

# Apply defaults to common renderers for cleaner global fig.show behavior.
apply_default_renderer_config()