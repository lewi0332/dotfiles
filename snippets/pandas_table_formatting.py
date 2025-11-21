import os
import pandas as pd
import numpy as np
import dataframe_image as dfi

# https://github.com/dexplo/dataframe_image


# simulated data for widget A
df_a = pd.DataFrame(
    {
        'Month':pd.date_range(
            start = '01-01-2012',
            end = '31-12-2022',
            freq = 'MS'
        ),#
        'Quotes':np.random.randint(
            low = 1_000_000,
            high = 2_500_000,
            size = 132
        ),
        'Numbers':np.random.randint(
            low = 300_000,
            high = 500_000,
            size = 132
        ),
        'Amounts':np.random.randint(
            low = 750_000,
            high = 1_250_000,
            size = 132
        )
    }
)

df_a['Product'] = 'A'

# simulated data for widget B
df_b = pd.DataFrame(
    {
        'Month':pd.date_range(
            start = '01-01-2012',
            end = '31-12-2022',
            freq = 'MS'
        ),
        'Quotes':np.random.randint(
            low = 100_000,
            high = 800_000,
            size = 132
        ),
        'Numbers':np.random.randint(
            low = 10_000,
            high = 95_000,
            size = 132
        ),
        'Amounts':np.random.randint(
            low = 450_000,
            high = 750_000,
            size = 132
        )
    }
)

df_b['Product'] = 'B'

# put it together & sort
df = pd.concat([df_a,df_b],axis = 0)
df.sort_values(by = 'Month',inplace = True)
df.reset_index(drop = True,inplace = True)


# average sale
df['Average sale'] = df['Amounts'] / df['Numbers']

# conversion
df['Product conversion'] = df['Numbers'] / df['Quotes']

# remove day of month from month column
df.style.format({'Month':'{:%Y-%m}'})

# use full name of month
df.style.format({'Month':'{:%B %Y}'})

# function to highlight rows based on average sale
def highlight_average_sale(s,sale_threshold = 5):
    r = pd.Series(data = False,index = s.index)
    r['Product'] = s.loc['Average sale'] > sale_threshold
    
    return ['background-color: yellow' if r.any() else '' for v in r]

# apply the formatting
df.iloc[:6,:].style\
.apply(highlight_average_sale,sale_threshold = 20, axis = 1)\
.format(
    {
        'Month':'{:%b %Y}',
        'Quotes':'{:,.0f}',
        'Numbers':'{:,.0f}',
        'Amounts':'£{:,.0f}',
        'Average sale':'£{:,.2f}',
        'Product conversion':'{:.2%}'
    }
)#.hide_index()

# create a total "row" - i.e. column total
total = df.drop(columns=['Month']).sum()
total['Month'] = pd.NaT
total['Product'] = ''
total['Average sale'] = total['Amounts'] / total['Numbers']
total['Product conversion'] = total['Numbers'] / total['Quotes']
total = total.to_frame().transpose()

# function to highlight the total row
def highlight_total(s):
    r = pd.Series(data = False,index = s.index)
    r['Month'] = pd.isnull(s.loc['Month'])
    
    return ['font-weight: bold' if r.any() else '' for v in r]

# function to conditionally highlight rows based on product
def highlight_product(s,product,colour = 'yellow'):
    r = pd.Series(data = False,index = s.index)
    r['Product'] = s.loc['Product'] == product
    
    return [f'background-color: {colour}' if r.any() else '' for v in r]

    # stack and reset index
d = pd.concat([df,total],axis = 0)
d.reset_index(drop = True,inplace = True)

# apply formatting
d_style = df.style\
.set_properties(**{'text-align':'center'})\
.apply(highlight_product,product = 'A',colour = '#DDEBF7',axis = 1)\
.apply(highlight_total,axis = 1)\
.format(
    {
        'Month':'{:%b %Y}',
        'Quotes':'{:,.0f}',
        'Numbers':'{:,.0f}',
        'Amounts':'�{:,.0f}',
        'Average sale':'�{:,.2f}',
        'Product conversion':'{:.2%}'
    },
    na_rep = 'Total'
)\
.set_caption('Sales data <br> Produced by Team X')
#.hide_index()




# export the table to PNG
dfi.export(
    d_style,
    'styled_dataframe.png'
    )
