import pandas as pd
from collections import defaultdict
import csv
import io
import sys
import subprocess

def getAdNameById(ad_id: str) -> str:
    return ad_map.get(ad_id, ad_id)



def parse_csv_and_iterate(file_path):
    """
    Reads a two-column CSV, checks for duplicates in the first column,
    and then iterates over the unique values of the first column, 
    providing access to the corresponding values of the second column.

    Args:
        file_path (str): The path to the CSV file.
    """
    
    try:
        # 1. Load the CSV into a pandas DataFrame
        df = pd.read_csv(file_path)
        # print("df initialized")
    except FileNotFoundError:
        print(f"Error: File not found at '{file_path}'")
        return
    except pd.errors.EmptyDataError:
        print("Error: The CSV file is empty.")
        return
    except pd.errors.ParserError:
        print("Error: Could not parse the CSV file. Check formatting.")
        return

    # Ensure the required columns exist
    COL1 = 'SpaceName'
    COL2 = 'PbaName'

    if COL1 not in df.columns or COL2 not in df.columns:
        print(f"Error: CSV must contain columns '{COL1}' and '{COL2}'.")
        print(f"Found columns: {list(df.columns)}")
        return

    # 2. Check for Duplicates in Column 1 ('spaceName')
    # This checks if the number of unique values is less than the total rows.
    total_rows = len(df)
    unique_names = df[COL1].nunique()
    
    if total_rows > unique_names:
        duplicate_count = total_rows - unique_names
        print(f"✅ Duplicate check complete: Found {duplicate_count} duplicate entries in '{COL1}'.")
    else:
        print(f"✅ Duplicate check complete: No duplicate entries found in '{COL1}'.")
    
    print("-" * 30)

    # 3. Structure the Data for Iteration (Grouping)
    # Group the DataFrame by 'spaceName' and aggregate 'pba' values into a list for each group.
    grouped_data = df.groupby(COL1)[COL2].apply(list).to_dict()

    # 4. Loop over every discrete value of 'spaceName'
    print(f"Starting iteration over {len(grouped_data)} unique '{COL1}' values:")
    
    for spaceName, pba_list in grouped_data.items():
        # 'spaceName' is the discrete value from column 1
        # 'pba_list' is a list of all corresponding values from column 2


        
        print(f"\nProcessing space: **{spaceName}**")
        print(f"  Found {len(pba_list)} associated 'pba' value(s).")

        print(f"\nEnriching {spaceName} to be an APM-Name")
        print(f"\n {spaceName} ", getAdNameById(spaceName))
        print("calling CURL")
        command = ["./curl-hub.sh", getAdNameById(spaceName)] + pba_list
        #command = ["./curl-hub.sh", spaceName] + pba_list
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        #print("Return code:" , result.returncode)
        print("Stdout:", result.stdout)
        #print("Sederr:", result.stderr)



        
        # --- YOUR LOGIC GOES HERE ---
        
        if len(pba_list) > 1:
            print("  ⚠️ **Duplicate 'spaceName' found!**")
            print(f"  All associated PBAs: {pba_list}")
            # Example: You could process or log the duplicate here
        else:
            print(f"  The single PBA is: {pba_list[0]}")
            # Example: You could assign the single value here
            
        # Example of iterating over the pba values if needed:
        # for pba_value in pba_list:
        #     # Do something with each individual pba value
        #     pass

    print("-" * 30)
    print("Iteration complete.")


df = pd.read_csv('./ad-id2name.csv', index_col='ad_Id') 
ad_map = df['ad_Name'].to_dict()   
parse_csv_and_iterate(sys.argv[1])
