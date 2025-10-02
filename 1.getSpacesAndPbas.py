import json
import subprocess
import sys
import csv
import os
import re
import shlex # Import shlex for safe command string manipulation
from typing import Dict, Any

def is_apm_space(text):
    return bool(re.search(r'ad-\d{8}', text))

def get_apm_id(text):
    """Extract the ad-XXXXXXXX pattern if it exists, otherwise return None."""
    match = re.search(r'ad-\d{8}', text)
    return match.group(0) if match else None

def execute_graphql_pipeline(curl_command_string: str, jq_filter: str) -> str:
    """
    Invokes a full shell pipeline, executing the provided curl command and 
    piping its output directly to the 'jq' filter.

    This method uses shell=True, combining both the curl command and the 
    jq filter into a single command line string executed by the shell.

    Args:
        curl_command_string: The complete curl command as a single string.
        jq_filter: The 'jq' filter string to apply to the JSON.

    Returns:
        The processed output string from the 'jq' command, which is now expected 
        to be a CSV-formatted string (one record per line).
    """
    
    # Construct the full pipeline command string: curl ... | jq 'filter'
    # We must ensure the jq filter is correctly quoted for the shell.
    # Safely quote the jq filter for the shell execution.
    quoted_jq_filter = shlex.quote(jq_filter)
    
    full_command = f"{curl_command_string} | jq -r {quoted_jq_filter}"
    # NOTE: Added '-r' (raw output) flag to jq so it doesn't wrap the CSV lines in quotes.
    
    print(f"--- Executing Full Pipeline Command ---")
    # Displaying a truncated command for cleaner output
    print(f"Command: {full_command[:100]}...")

    try:
        # Using subprocess.run with shell=True to execute the pipeline command string.
        result = subprocess.run(
            full_command,
            shell=True,
            capture_output=True, # Capture stdout and stderr
            text=True,           # Use text mode for automatic string encoding/decoding
            check=False          # Do not raise an exception on non-zero exit code
        )

        # Check for errors (non-zero exit code)
        if result.returncode != 0:
            print(f"\nPipeline command failed (Exit Code {result.returncode}).", file=sys.stderr)
            
            # Print combined error output (curl or jq)
            error_message = result.stderr.strip()
            if error_message:
                print(f"Error Message:\n{error_message}", file=sys.stderr)
            else:
                print("No specific error message returned by the shell.", file=sys.stderr)
            
            # Check for 'jq' or 'curl' missing specifically
            if "not found" in error_message or "No such file" in error_message:
                # Re-raise the specific error for clear user guidance
                raise FileNotFoundError()
                
            return ""

        return result.stdout.strip()

    except FileNotFoundError:
        print("\n--- CRITICAL ERROR ---", file=sys.stderr)
        print("One of the required commands ('curl' or 'jq') was not found.", file=sys.stderr)
        print("Please ensure both are installed and accessible in your system's PATH.", file=sys.stderr)
        print("----------------------", file=sys.stderr)
        return ""
    except Exception as e:
        print(f"An unexpected error occurred during subprocess execution: {e}", file=sys.stderr)
        return ""


# --- Main Execution Block ---

# 0. Retrieve the Bearer Token from the environment variable 'htoken'
bearer_token = os.getenv('htoken')

if not bearer_token:
    print("\nWARNING: Environment variable 'htoken' not set.", file=sys.stderr)
    # Use a placeholder token for command construction, though the API call will likely fail without a real token.
    bearer_token = "PLACEHOLDER_TOKEN"
    print(f"Using placeholder token '{bearer_token}' for command construction. Set 'htoken' for real authentication.", file=sys.stderr)
else:
    print("\nBearer token retrieved successfully from 'htoken' environment variable.")

# 1. Define the BASE curl command provided by the user (Altair client)
# NOTE: This is the user's specific curl command string.
CURL_BASE_COMMAND = """
curl 'https://hub.homelab1.fynesy.com/hub/graphql?query=query%7BentityQuery%7BqueryEntities(entityType%3A%22Tanzu.TAS.Space%22%2Cfirst%3A10000)%7Bentities%7BentityId%20entityName%20entitiesIn(entityType%3A%22Tanzu.Hub.PotentialBusinessApplication%22)%7Bentities%7BentityId%20entityName%20properties%7Bname%20value%7D%7D%7DentitiesOut(entityType%3A%22Tanzu.TAS.Organization%22)%7Bentities%7BentityId%20entityName%7D%7D%7D%7D%7D%7D&variables=%7B%7D' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'Connection: keep-alive' -H 'Origin: altair://-' --compressed
""".strip()

# 2. Define the new Authorization header string
AUTH_HEADER = f"-H 'Authorization: Bearer {bearer_token}'"

# 3. Inject the Authorization header into the base command string.
# We insert the new header after the initial 'curl ' prefix.
if CURL_BASE_COMMAND.startswith('curl '):
    # Strip 'curl ' (5 chars) and prepend the full command with 'curl {AUTH_HEADER} '
    curl_command_string = f"curl {AUTH_HEADER} {CURL_BASE_COMMAND[5:]}"
else:
    # Fallback construction if the curl command format is unexpected
    curl_command_string = f"{CURL_BASE_COMMAND} {AUTH_HEADER}"


# 4. Define the 'jq' filter expression for TWO-FIELD CSV output
# This filter iterates over entities, creates an array with two fields (.entityId, .entityName),
# and uses the @csv format to output comma-separated values.
jq_filter_expression = """
"SpaceName,PbaName", 
(.data.entityQuery.queryEntities.entities[] | [.entityName, .entitiesIn.entities[0].entityId] | @csv)
"""
# Note: The first line adds a header row for the CSV output.
#(.data.entityQuery.queryEntities.entities[] | [.entityId, .entityName] | @csv)


# 5. Run the function and display the result
# NOTE: This script requires 'curl' and 'jq' to be installed and accessible.
final_result = execute_graphql_pipeline(curl_command_string, jq_filter_expression)

if final_result:
    print("\n=============================================")
    print("JQ RESULT (Two-Field CSV List):")
    print("This output is ready to save to a .csv file.")
    print("---------------------------------------------")
    print(final_result)

    SPACES_WITH_PBAS_FILENAME="spaces_with_pbas.csv"
    try:
        with open(SPACES_WITH_PBAS_FILENAME, 'w', encoding='utf-8') as f:
            f.write("\"SpaceName\",\"PbaName\"\n")
            spaces = final_result.splitlines()
            apm_spaces = [space for space in spaces if is_apm_space(space)]
            #for i in apm_spaces:
            #    print("i = " + i)
            
            apm_ids = []
            
            reader = csv.reader(apm_spaces, delimiter=',', quotechar='"')
            for apm_space in reader:
                print("apm_id= " + apm_space[0])
                apm_id = get_apm_id(apm_space[0])
                print("pba= " + apm_space[1])
                apm_ids.append(apm_id + "," + apm_space[1])
            f.write('\n'.join(apm_ids))
            f.write('\n')

            # for apm_space in apm_spaces:
                #print("apm_space: " + apm_space)
            #     print("apm_id: " + apm_id)
            #     print("apm_space[1]: " + apm_space[0])

            #f.write(final_result + "\n")
        print(f"\nCSV Created")
    except IOError as e:
        print(f"\nERROR: could not write to csv file")

    print("=============================================")
else:
    print("\nProcessing failed or returned no data.")
