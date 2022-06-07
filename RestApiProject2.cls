/* {
    "AbsentDate" : "2022-02-02",
    "AbsentType" : "OFF",
    "AbsentPeriod" : "FULL",
    "Reason" : "hihi",
    "LateHours" : "1",
    "LateMinutes" : "15",
    "AbsentToDate" : "2022-02-02",
    "DontSendEmail" : "true",
    "Email" : "psunrise@trailhead.com"
    } */

@RestResource(urlMapping='/teta/*')

global with sharing class RestApiProject2 {
    @AuraEnabled(cacheable=true)

    @HttpGet
    global static Absent_Log__c doGet() {
        RestRequest request = RestContext.request;
        String oppId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        Absent_Log__c result = [SELECT Absent_Date__c, DontSendEmail__c, Late_Hours__c, Late_Minutes__c, Absent_Period__c, 
                                Absent_To_Date__c, Absent_Type__c, Email__c, Reason__c FROM Absent_Log__c WHERE Id= :oppId];
        return result;
    }

    global class Absent {
        global String AbsentDate;
        global String AbsentToDate;
        global String LateHours;
        global String LateMinutes;
        global String Reason;
        global String AbsentType;
        global String AbsentPeriod;
        global String DontSendEmail;

        global Absent(String AbsentDate, String AbsentToDate, String LateHours, String LateMinutes, String Reason, String AbsentType, String AbsentPeriod, String DontSendEmail) {
            this.AbsentDate = AbsentDate;
            this.AbsentToDate = AbsentToDate;
            this.LateHours = LateHours;
            this.LateMinutes = LateMinutes;
            this.Reason = Reason;
            this.AbsentType = AbsentType;
            this.AbsentPeriod = AbsentPeriod;
            this.DontSendEmail = DontSendEmail;
        }
    }

    global class Response {
        global Boolean isSuccess { get; set; }
        global String message { get; set; }
    }

    global class AbsentException extends Exception { 
    }

    @HttpPost
    global static Response doPost(Absent abs, String Email) {
        Absent_Log__c absent = new Absent_Log__c();
        Response apiResponse = new Response();
        try {
            Contact idcon = new Contact();
            apiResponse.isSuccess = ![SELECT id FROM Contact WHERE Email = :Email].isEmpty();
            
            if (apiResponse.isSuccess && String.isNotBlank(Email)) {
                apiResponse.message = 'Success';
                idcon = [SELECT id FROM Contact WHERE Email = :Email limit 1];
                absent.Absent_Date__c = Date.valueOf(abs.AbsentDate);
                absent.Absent_Type__c = abs.AbsentType;
                absent.Absent_Period__c = abs.AbsentPeriod;
                absent.Reason__c = abs.Reason;
                absent.Late_Hours__c = abs.LateHours;
                absent.Late_Minutes__c = abs.LateMinutes;
                absent.Absent_To_Date__c = Date.valueOf(abs.AbsentToDate);
                absent.DontSendEmail__c = Boolean.valueOf(abs.DontSendEmail);
                absent.Contact__c = idcon.id;
                insert absent;
            } else {
                apiResponse.isSuccess = false;
                apiResponse.message = 'Email Invalid';
                return apiResponse;
            }
        } catch (AbsentException ex) {
            apiResponse.message = 'Email Invalid';
            return apiResponse;
        }
        return apiResponse;
    }
}
