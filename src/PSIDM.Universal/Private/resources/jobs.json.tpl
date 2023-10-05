{
  "JobList": [
    {
      "JobId": "a2290ab1-24fa-4677-bea7-8f1427268e37",
      "JobScript": "onboard.ps1",
      "JobName": "onboard",
      "JobPickupFile": "onboard.csv"
    },
    {
      "JobId": "a839b642-c31b-4bb8-8c9e-14cfeebb7cb7",
      "JobPickupFile": "offboard.csv",
      "JobName": "offboard",
      "JobScript": "offboard.ps1",
      "RequiredHeaders": [
        "EmpDispName",
        "Upn",
        "SamAcct",
        "RequestorId"
      ],
      "ADPropertyMap": [
        {
          "Source": "EmpDispName",
          "Destination": "DisplayName"
        },
        {
          "Source": "Upn",
          "Destination": "UserPrincipalName"
        },
        {
          "Source": "SamAcct",
          "Destination": "SamAccountName"
        }
      ]
    },
    {
      "JobId": "ff2140e7-34d2-47b3-96a0-8892dea7b085",
      "JobScript": "update.ps1",
      "JobName": "update",
      "JobPickupFile": "update.csv"
    }
  ]
}
