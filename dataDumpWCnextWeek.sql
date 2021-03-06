/****** Data Dump of all appointments scheduled to take place next week in the Women’s Center ******/

/*Care Provider Resource Count (number of care providers set to attend the appointment)
*/

/*Main
*/
SELECT 
	
	appt.[AppointmentID]
	,appt.[ScheduledStartDtm] as [Scheduled Start Datetime]
	,appt.[ScheduledEndDtm] as [Scheduled End Datetime]

	,eve.EventName as [Event Name]
	,loc.Name as [Location]
	,DATEDIFF( minute, appt.[ScheduledStartDtm], appt.[ScheduledEndDtm] ) as [Scheduled Duration Minutes]
	
	,vis.[VisitIDCode] as [VisitNbr]

	,REPLACE( vis.[IDCode], '-', '' ) as [visit MRN]
	,vis.[ClientDisplayName] as [Visit name]
	,client.[IDCode] as [Client MRN wrong]
	,client.[DisplayName] as [Client name]
	,billCharge.MRN as [Bill MRN]
	
	,COUNT( distinct careProvRes.CareProviderGUID ) as [BONUS - Appointment Care Provider Resource Count]

----------------------------------------------
  FROM [FI_DM_EBI].[dbo].[AllScripts_SXAESAppointment] appt (nolock)

  --With (NOLOCK)
   
  LEFT JOIN [AllScripts_SXAESEvent] eve (nolock)
	ON appt.EventID = eve.EventID

  LEFT JOIN [AllScripts_CV3Location] loc (nolock)
	ON appt.LocationGUID = loc.GUID

  LEFT JOIN [AllScripts_CV3ClientVisit] vis (nolock)
	ON appt.[ClientVisitGUID] = vis.GUID

  LEFT JOIN [AllScripts_CV3Client] client (nolock)
	ON appt.[ClientGUID] = client.GUID

  LEFT JOIN [AllScripts_SXAAMBSBillChargeHeader] billCharge (nolock)
	ON appt.[ClientGUID] = billCharge.ClientGUID

  /*Care Provider Resource Count (number of care providers set to attend the appointment)
  */
  INNER JOIN [AllScripts_SXAESApptEvtResourceXREF] apptRes (nolock)
	ON appt.AppointmentID = apptRes.AppointmentID
  
  
  LEFT JOIN [AllScripts_SXAESCareProviderResource] careProvRes (nolock)
	ON apptRes.[ResourceID] = careProvRes.[ResourceID]
	/**/

--Criteria-------------------------------------------------

WHERE

  --Exclude cancelled appointments
  appt.[AppointmentStatus] <> 'CANCELLED'

  --Appointments set to take place in Women’s Center only
  AND loc.Name = 'Women''s Center'

  --Appointments scheduled to take place next week (Sunday to Saturday)
  --Okay to hardcode date range in query
  AND appt.[ScheduledStartDtm] BETWEEN '2017-03-05' AND '2017-03-11'

  -- QA ------------------------------

  -- for counting--------------------------------------
  GROUP BY appt.AppointmentID 
	,appt.[ScheduledStartDtm]
	,appt.[ScheduledEndDtm] 
	,eve.[EventName]
	,loc.[Name]
	,vis.[VisitIDCode]
	
	,vis.[IDCode]
	,vis.[ClientDisplayName]
	
	,client.[IDCode]
	,client.[DisplayName]
	,billCharge.[MRN]

	/**/
