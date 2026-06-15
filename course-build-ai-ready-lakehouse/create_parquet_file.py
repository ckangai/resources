import pandas as pd
import numpy as np

# 1. Create a dummy dataset (e.g., mock e-commerce transactions)
n_rows = 100000
data = {
    'transaction_id': np.arange(1, n_rows + 1),
    'user_id': np.random.randint(1000, 9999, size=n_rows),
    'amount': np.random.uniform(10.0, 500.0, size=n_rows).round(2),
    'category': np.random.choice(['Electronics', 'Books', 'Clothing', 'Home'], size=n_rows),
    'timestamp': pd.date_range(start='2026-01-01', periods=n_rows, freq='s')
}

df = pd.DataFrame(data)

# 2. Save directly to a local Parquet file using snappy compression
df.to_parquet('demo_transactions.parquet', compression='snappy', index=False)

print("Parquet file created successfully!")