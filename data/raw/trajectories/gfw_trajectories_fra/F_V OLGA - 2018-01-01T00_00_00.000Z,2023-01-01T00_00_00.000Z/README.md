
# Global Fishing Watch Map Tracks

The downloaded file provides basic track information for a vessel of interest.

## Schema of the file

Lon: longitude in decimal degrees
Lat: latitude decimal degrees
Timestamp: timestamp for AIS position in UTC
Speed: speed (knots) of vessel transmitted by AIS
Course: course (direction) of vessel transmitted by AIS
Seg_id: Unique identifier for the segment of AIS


## Caveats

The track information is derived from the AIS sources AIS sources; Orbcom 2012 to June 2016, Orbomm and Spire June 2016 to December 2022, Spire Global January 2023. Segment ID is an internal unit used at Global Fishing Watch as part of the process for ensuring valid AIS positional data is linked together into a coherent track.

AIS data is limited by those vessels that transmit AIS data and do so by entering accurate vessel identity information in the transmitter. Track information and segment ID are all impacted by quality of AIS data. Vessels transmitting in low reception areas, with class B AIS,  transmitting intermittently, or vessels that turn their AIS off for long periods of time (when in port for example) are more likely to have numerous Vessel IDs associated with the same physical vessel, gaps in track information, or other possible inconsistencies.

While there is no definitive solution to this issue since it is inherent to the nature of AIS, GFW continues to develop methods to identify the true track for a single physical vessel over time.

Some points of the track are removed for license restriction with our data providers. If the full track is needed, please contact Global Fishing Watch Support <support@globalfishingwatch.org>.

## License

Non-Commercial Use Only. The Site and the Services are provided for Non-Commercial use only in accordance with the CC BY-NC 4.0 license. If you would like to use the Site and/or the Services for commercial purposes, please contact us.

Meta data:

Dataset Id used to generate the export: public-global-all-tracks:v20231026
Vessel Id: 295b292c3-343c-1b9f-e08c-95d59e36c119,b456c9aca-ad72-73a5-4f62-d96264a0e593,e71bb5a8f-f04b-1676-4f64-f6f530320ad2
Time Range: 2018-01-01T00:00:00.000Z,2023-01-01T00:00:00.000Z

