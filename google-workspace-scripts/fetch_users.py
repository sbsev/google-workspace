# %%
import os.path

import matplotlib.pyplot as plt
import pandas as pd
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/admin.directory.user"]


# Shows basic usage of the Admin SDK Directory API. Prints the emails and names of the first 10 users in the domain.
creds = None
# The file token.json stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
# If there are no (valid) credentials available, let the user log in.
if not creds:  # or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
        creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open("token.json", "w") as token:
        token.write(creds.to_json())

service = build("admin", "directory_v1", credentials=creds)


# %%
# Call the Admin SDK Directory API
print("Getting users in domain")
results = (
    service.users()
    .list(customer="my_customer", maxResults=500, orderBy="email")
    .execute()
)
users = pd.DataFrame(results.get("users", []))


# %%
users["lastLoginTime"] = users["lastLoginTime"].astype("datetime64")
users["creationTime"] = users["creationTime"].astype("datetime64")


# %%
users[users.agreedToTerms].groupby(
    users["lastLoginTime"].dt.month
).lastLoginTime.count().plot(kind="bar")

plt.savefig("last-signin-by-month.pdf")


# %%
users.groupby(users["creationTime"].dt.year).creationTime.count().plot(kind="bar")

plt.savefig("creation-by-year.pdf")
