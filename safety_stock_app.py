import streamlit as st
import pandas as pd
import numpy as np
from scipy.stats import norm

st.title('Safety Stock Calculator')

# Upload file
uploaded_file = st.file_uploader("Choose a file (Excel format)", type=['xlsx'])
if uploaded_file is not None:
    df = pd.read_excel(uploaded_file, sheet_name='Sheet1')

    # Inputs for calculation
    cost_per_unit = st.number_input('Cost per unit', value=3.25)
    holding_cost_rate = st.number_input('Holding cost rate', value=0.08)
    opportunity_cost_rate = st.number_input('Opportunity cost rate', value=0.05)
    lead_time_weeks = st.number_input('Lead time in weeks', value=2)
    service_level = st.number_input('Service level (as a decimal)', value=0.92)

    if st.button('Calculate Safety Stock'):
        # Calculate the mean and standard deviation of daily demand
        mean_demand = df["Locking Mechanism Demand"].mean()
        std_demand = df["Locking Mechanism Demand"].std()

        # Convert weekly lead time to daily by multiplying by 7
        lead_time_days = lead_time_weeks * 7

        # Calculate Z-score for given service level
        z_score = norm.ppf(service_level)

        # Calculate safety stock
        safety_stock = z_score * (std_demand * np.sqrt(lead_time_days))
        safety_stock = np.ceil(safety_stock)

        st.write(f'The calculated safety stock is: {safety_stock}')
