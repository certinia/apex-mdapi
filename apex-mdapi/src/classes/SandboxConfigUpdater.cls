/*
 * Copyright (c) 2025 Citigroup Inc. All rights reserved.
 * 
 * File Name: SandboxConfigUpdater.cls
 * Created By: Prakhar Agrawal
 * Created Date: May 18, 2025
 * Last Modified By: Prakhar Agrawal
 * Last Modified Date: May 22, 2025 04:05 PM IST
 * 
 * Description: Apex class to update sandbox configuration settings based on the environment name.
 *              Updates Custom Settings, CRS_Global_Auth_Headers__c, CRS_StaticValues__c, and CRS_SSO_SAML_Mapping__mdt with environment-specific values.
 * 
 * Usage: Execute the updateSettings() method to apply environment-specific configurations.
 * 
 * Confidentiality Notice: This code contains confidential and proprietary information of Citigroup Inc.
 *                        It is intended for internal use only and may not be disclosed to third parties
 *                        without prior written consent.
 */

/**
 * @description Updates sandbox configuration settings based on the environment name.
 *              This class handles updates for various Custom Settings, including CRS_Global_Auth_Headers__c, 
 *              CRS_StaticValues__c, and CRS_SSO_SAML_Mapping__mdt, ensuring they have environment-specific values.
 */
public class SandboxConfigUpdater {

    // Map of standard environment names to client_id values
    private static final Map<String, String> ENV_TO_CLIENT_ID = new Map<String, String> {
        'DEV 1' => 'da4d6ed4-6fdf-4f96-9c9b-b9f93f9d291f',
        'DEV 2' => '66952180-8ae0-494e-a992-bd79fe0c8db3',
        'DEV 3' => '4e440dd7-e3dd-4cd5-b092-0e59c8596100',
        'UAT 1' => 'b8af35d7-30a4-43a6-853d-ca96d553bbab',
        'UAT 2' => 'e8b8a730-eb0b-471b-9b12-21642c2ab4ba',
        'UAT 3' => 'b723aefc-0a28-4d38-8d77-f71429bc1c51',
        'UAT 4' => 'ee4dc7fe-0ed4-4c7f-bcab-83fce98b8e4c',
        'PERF' => '070123b2-02e7-47ea-a4fe-bcfc716a62bc',
        'PILOT' => '7a578bb9-f0dd-4611-a537-a28f6e79e370',
        'PROD' => '541eeceb-9c54-4b32-9aae-03a167a4e527'
    };

    // Map of sandbox environment names to standard environment names
    private static final Map<String, String> SANDBOX_ENV_TO_STANDARD_ENV = new Map<String, String> {
        'test' => 'DEV 1',
        'dev1' => 'DEV 1',
        'dev2' => 'DEV 2',
        'dev3' => 'DEV 3',
        'uat1' => 'UAT 1',
        'uat2' => 'UAT 2',
        'uat3' => 'UAT 3',
        'uat4' => 'UAT 4',
        'perf' => 'PERF',
        'pilot' => 'PILOT',
        'prod' => 'PROD'
    };

    // Inner class to represent a standard CRS_StaticValues__c record
    private class StaticValueStandard {
        String name;
        String parameterName;
        String parameterValue;
        String subUrl;

        StaticValueStandard(String name, String parameterName, String parameterValue, String subUrl) {
            this.name = name;
            this.parameterName = parameterName;
            this.parameterValue = parameterValue;
            this.subUrl = subUrl;
        }

        // Generate a unique key for comparison
        String getKey() {
            return name + '|' + parameterName + '|' + subUrl;
        }
    }

    // Defines the standard set of CRS_StaticValues__c records.
    // These records are used to ensure consistency across environments.
    private static final List<StaticValueStandard> STANDARD_STATIC_VALUES = new List<StaticValueStandard> {
        // For Sub URL /api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate, 
        // there are 6 records, split into two sets of 3 for two different CRS_Integration_Headers__c records.
        // First set for the first CRS_Integration_Headers__c record:
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        // Second set for the second CRS_Integration_Headers__c record:
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        // For Sub URL /api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete (3 records):
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete'),
        // For Sub URL /api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve (3 records):
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve')
    };

    /**
     * @description Maps sandbox environment names to specific URL segments for CRS_Call_Recording_Settings__c.
     * @param envName The original sandbox environment name (e.g., "dev1", "uat1").
     * @return The mapped environment name segment to be used in URLs (e.g., "uat1").
     */
    private static String getMappedEnvNameForCallRecording(String envName) {
        if (envName == 'uat1' || envName == 'dev1') {
            return 'uat1';
        } else if (envName == 'uat2' || envName == 'dev2') {
            return 'uat2';
        } else if (envName == 'uat3' || envName == 'dev3') {
            return 'uat3';
        }
        return envName; // Default to original envName for other values
    }

    /**
     * @description Maps sandbox environment names to specific URL segments for CRS_iFrame_URLs__c.
     * @param envName The original sandbox environment name (e.g., "dev1", "uat1").
     * @return The mapped environment name segment to be used in URLs (e.g., "uat").
     */
    private static String getMappedEnvNameForIframeUrls(String envName) {
        if (envName == 'uat1') {
            return 'uat';
        } else if (envName == 'dev1') {
            return 'dev1';
        } else if (envName == 'uat2') {
            return 'uat2';
        } else if (envName == 'uat3') {
            return 'uat3';
        } else if (envName == 'dev2') {
            return 'dev2';
        } else if (envName == 'dev3') {
            return 'dev3';
        }
        return envName; // Default to original envName for other values
    }

    /**
     * @description Maps sandbox environment names to specific URL segments for CRS_System_Settings__c.
     * @param envName The original sandbox environment name (e.g., "dev1", "uat1").
     * @return The mapped environment name segment to be used in URLs (e.g., "uat1").
     */
    private static String getMappedEnvNameForSystemSettings(String envName) {
        if (envName == 'uat1' || envName == 'dev1') {
            return 'uat1';
        } else if (envName == 'uat2' || envName == 'dev2') {
            return 'uat2';
        } else if (envName == 'uat3' || envName == 'dev3') {
            return 'uat3';
        }
        return envName; // Default to original envName for other values
    }

    /**
     * @description Updates various Custom Settings (CRS_Call_Recording_Settings__c, CRS_iFrame_URLs__c, CRS_System_Settings__c),
     *              CRS_Global_Auth_Headers__c, CRS_StaticValues__c, and CRS_SSO_SAML_Mapping__mdt metadata records
     *              with values based on the environment name retrieved from SandboxEnvironmetConfig__c.
     * @throws CustomException if required Custom Setting records are missing, invalid, 
     *                         or if DML operations or Metadata API updates fail.
     */
    public static void updateSettings() {
        // Retrieve environment and sandbox name from SandboxEnvironmetConfig__c (Hierarchy Custom Setting)
        SandboxEnvironmetConfig__c config = SandboxEnvironmetConfig__c.getOrgDefaults();
        if (config == null || String.isBlank(config.EnvironmentName__c)) {
            throw new CustomException('Custom Setting "SandboxEnvironmetConfig" with name "Default" not found or EnvironmentName__c is blank.');
        }
        String envName = config.EnvironmentName__c.toLowerCase();
        System.debug('Retrieved EnvironmentName__c from SandboxEnvironmetConfig__c: ' + envName);

        // Retrieve Sandbox_Name__c for CRS_SSO_SAML_Mapping__mdt update
        String sandboxName = config.Sandbox_Name__c;
        if (String.isBlank(sandboxName)) {
            throw new CustomException('Sandbox_Name__c is blank in SandboxEnvironmetConfig__c for environment: ' + envName);
        }
        System.debug('Retrieved Sandbox_Name__c from SandboxEnvironmetConfig__c: ' + sandboxName);

        // Map the retrieved sandbox environment name to a standard environment name (e.g., "dev1" to "DEV 1")
        String standardEnv = SANDBOX_ENV_TO_STANDARD_ENV.get(envName);
        if (standardEnv == null) {
            throw new CustomException('Environment name "' + envName + '" not recognized. Expected values are: ' + SANDBOX_ENV_TO_STANDARD_ENV.keySet());
        }
        System.debug('Mapped sandbox environment "' + envName + '" to standard environment "' + standardEnv + '".');

        // Get the expected client_id for the standard environment
        String expectedClientId = ENV_TO_CLIENT_ID.get(standardEnv);
        if (expectedClientId == null) {
            throw new CustomException('No client_id value found for standard environment "' + standardEnv + '".');
        }
        System.debug('Expected client_id for standard environment "' + standardEnv + '": ' + expectedClientId);

        // Construct the expected targetApigeeHost value using the original environment name
        String expectedApigeeHost = envName + '.secure2.assistedchannel.nam.pbwm.citigroup.net';
        System.debug('Expected targetApigeeHost for environment "' + envName + '": ' + expectedApigeeHost);

        // Update CRS_Call_Recording_Settings__c records
        String callRecordingEnv = getMappedEnvNameForCallRecording(envName);
        // Update the "CallRecordingDetails" record
        CRS_Call_Recording_Settings__c callRecordingDetails = CRS_Call_Recording_Settings__c.getValues('CallRecordingDetails');
        if (callRecordingDetails == null) {
            throw new CustomException('CRS_Call_Recording_Settings__c record with Name "CallRecordingDetails" not found.');
        }
        Boolean callRecordingDetailsNeedsUpdate = false;
        String expectedLoadBalancingUrl = 'B178542-vip.nam.nsroot.net';
        String expectedRsiClientUrl = 'https://ast-svc-v-voicecallrecordingweb-sw1' + callRecordingEnv + '.apps-sw1-dev.nam.nsroot.net/rsi/recording-system/index';
        String expectedStopRecordingUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + callRecordingEnv + '/api/private/v1/callRecording/termination';
        String expectedUpdateBusinessDataUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + callRecordingEnv + '/api/private/v1/callRecording/businessData';

        if (callRecordingDetails.CRS_Load_Balancing_URL__c != expectedLoadBalancingUrl) {
            System.debug('Updating CRS_Load_Balancing_URL__c for "CallRecordingDetails" record. Current: ' + callRecordingDetails.CRS_Load_Balancing_URL__c + ', Expected: ' + expectedLoadBalancingUrl);
            callRecordingDetails.CRS_Load_Balancing_URL__c = expectedLoadBalancingUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_Load_Balancing_URL__c for "CallRecordingDetails" record is already correct: ' + callRecordingDetails.CRS_Load_Balancing_URL__c);
        }
        if (callRecordingDetails.CRS_RSI_Client_URL__c != expectedRsiClientUrl) {
            System.debug('Updating CRS_RSI_Client_URL__c for "CallRecordingDetails" record. Current: ' + callRecordingDetails.CRS_RSI_Client_URL__c + ', Expected: ' + expectedRsiClientUrl);
            callRecordingDetails.CRS_RSI_Client_URL__c = expectedRsiClientUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_RSI_Client_URL__c for "CallRecordingDetails" record is already correct: ' + callRecordingDetails.CRS_RSI_Client_URL__c);
        }
        if (callRecordingDetails.CRS_Stop_Recording_URL__c != expectedStopRecordingUrl) {
            System.debug('Updating CRS_Stop_Recording_URL__c for "CallRecordingDetails" record. Current: ' + callRecordingDetails.CRS_Stop_Recording_URL__c + ', Expected: ' + expectedStopRecordingUrl);
            callRecordingDetails.CRS_Stop_Recording_URL__c = expectedStopRecordingUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_Stop_Recording_URL__c for "CallRecordingDetails" record is already correct: ' + callRecordingDetails.CRS_Stop_Recording_URL__c);
        }
        if (callRecordingDetails.CRS_Update_Business_Data_URL__c != expectedUpdateBusinessDataUrl) {
            System.debug('Updating CRS_Update_Business_Data_URL__c for "CallRecordingDetails" record. Current: ' + callRecordingDetails.CRS_Update_Business_Data_URL__c + ', Expected: ' + expectedUpdateBusinessDataUrl);
            callRecordingDetails.CRS_Update_Business_Data_URL__c = expectedUpdateBusinessDataUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_Update_Business_Data_URL__c for "CallRecordingDetails" record is already correct: ' + callRecordingDetails.CRS_Update_Business_Data_URL__c);
        }

        if (callRecordingDetailsNeedsUpdate) {
            update callRecordingDetails;
            System.debug('Successfully updated CRS_Call_Recording_Settings__c record "CallRecordingDetails".');
        } else {
            System.debug('No updates needed for CRS_Call_Recording_Settings__c record "CallRecordingDetails".');
        }

        // Update the "CallRecordingDetails_SW" record
        CRS_Call_Recording_Settings__c callRecordingDetailsSW = CRS_Call_Recording_Settings__c.getValues('CallRecordingDetails_SW');
        if (callRecordingDetailsSW == null) {
            throw new CustomException('CRS_Call_Recording_Settings__c record with Name "CallRecordingDetails_SW" not found.');
        }
        Boolean callRecordingDetailsSWNeedsUpdate = false;
        if (callRecordingDetailsSW.CRS_Load_Balancing_URL__c != expectedLoadBalancingUrl) {
            System.debug('Updating CRS_Load_Balancing_URL__c for "CallRecordingDetails_SW" record. Current: ' + callRecordingDetailsSW.CRS_Load_Balancing_URL__c + ', Expected: ' + expectedLoadBalancingUrl);
            callRecordingDetailsSW.CRS_Load_Balancing_URL__c = expectedLoadBalancingUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_Load_Balancing_URL__c for "CallRecordingDetails_SW" record is already correct: ' + callRecordingDetailsSW.CRS_Load_Balancing_URL__c);
        }
        if (callRecordingDetailsSW.CRS_RSI_Client_URL__c != expectedRsiClientUrl) {
            System.debug('Updating CRS_RSI_Client_URL__c for "CallRecordingDetails_SW" record. Current: ' + callRecordingDetailsSW.CRS_RSI_Client_URL__c + ', Expected: ' + expectedRsiClientUrl);
            callRecordingDetailsSW.CRS_RSI_Client_URL__c = expectedRsiClientUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_RSI_Client_URL__c for "CallRecordingDetails_SW" record is already correct: ' + callRecordingDetailsSW.CRS_RSI_Client_URL__c);
        }
        if (callRecordingDetailsSW.CRS_Stop_Recording_URL__c != expectedStopRecordingUrl) {
            System.debug('Updating CRS_Stop_Recording_URL__c for "CallRecordingDetails_SW" record. Current: ' + callRecordingDetailsSW.CRS_Stop_Recording_URL__c + ', Expected: ' + expectedStopRecordingUrl);
            callRecordingDetailsSW.CRS_Stop_Recording_URL__c = expectedStopRecordingUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_Stop_Recording_URL__c for "CallRecordingDetails_SW" record is already correct: ' + callRecordingDetailsSW.CRS_Stop_Recording_URL__c);
        }
        if (callRecordingDetailsSW.CRS_Update_Business_Data_URL__c != expectedUpdateBusinessDataUrl) {
            System.debug('Updating CRS_Update_Business_Data_URL__c for "CallRecordingDetails_SW" record. Current: ' + callRecordingDetailsSW.CRS_Update_Business_Data_URL__c + ', Expected: ' + expectedUpdateBusinessDataUrl);
            callRecordingDetailsSW.CRS_Update_Business_Data_URL__c = expectedUpdateBusinessDataUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_Update_Business_Data_URL__c for "CallRecordingDetails_SW" record is already correct: ' + callRecordingDetailsSW.CRS_Update_Business_Data_URL__c);
        }

        if (callRecordingDetailsSWNeedsUpdate) {
            update callRecordingDetailsSW;
            System.debug('Successfully updated CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW".');
        } else {
            System.debug('No updates needed for CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW".');
        }

        // Update CRS_iFrame_URLs__c records
        String iframeEnv = getMappedEnvNameForIframeUrls(envName);
        // Update the "CRS_PaymentOriginUAT" record
        CRS_iFrame_URLs__c paymentOrigin = CRS_iFrame_URLs__c.getValues('CRS_PaymentOriginUAT');
        if (paymentOrigin == null) {
            throw new CustomException('CRS_iFrame_URLs__c record with Name "CRS_PaymentOriginUAT" not found.');
        }
        Boolean paymentOriginNeedsUpdate = false;
        String expectedPaymentOriginUrl = 'https://' + iframeEnv + '.payment.citiretailservices.citigroup.net';
        if (paymentOrigin.iFrame_URL__c != expectedPaymentOriginUrl) {
            System.debug('Updating iFrame_URL__c for "CRS_PaymentOriginUAT" record. Current: ' + paymentOrigin.iFrame_URL__c + ', Expected: ' + expectedPaymentOriginUrl);
            paymentOrigin.iFrame_URL__c = expectedPaymentOriginUrl;
            paymentOriginNeedsUpdate = true;
        } else {
            System.debug('iFrame_URL__c for "CRS_PaymentOriginUAT" record is already correct: ' + paymentOrigin.iFrame_URL__c);
        }

        if (paymentOriginNeedsUpdate) {
            update paymentOrigin;
            System.debug('Successfully updated CRS_iFrame_URLs__c record "CRS_PaymentOriginUAT".');
        } else {
            System.debug('No updates needed for CRS_iFrame_URLs__c record "CRS_PaymentOriginUAT".');
        }

        // Update the "CRS_PaymentSourceUAT" record
        CRS_iFrame_URLs__c paymentSource = CRS_iFrame_URLs__c.getValues('CRS_PaymentSourceUAT');
        if (paymentSource == null) {
            throw new CustomException('CRS_iFrame_URLs__c record with Name "CRS_PaymentSourceUAT" not found.');
        }
        Boolean paymentSourceNeedsUpdate = false;
        String expectedPaymentSourceUrl = 'https://' + iframeEnv + '.payment.citiretailservices.citigroup.net/contact-center?pageName=payments&siteId=app_rplid&appName=olympus';
        if (paymentSource.iFrame_URL__c != expectedPaymentSourceUrl) {
            System.debug('Updating iFrame_URL__c for "CRS_PaymentSourceUAT" record. Current: ' + paymentSource.iFrame_URL__c + ', Expected: ' + expectedPaymentSourceUrl);
            paymentSource.iFrame_URL__c = expectedPaymentSourceUrl;
            paymentSourceNeedsUpdate = true;
        } else {
            System.debug('iFrame_URL__c for "CRS_PaymentSourceUAT" record is already correct: ' + paymentSource.iFrame_URL__c);
        }

        if (paymentSourceNeedsUpdate) {
            update paymentSource;
            System.debug('Successfully updated CRS_iFrame_URLs__c record "CRS_PaymentSourceUAT".');
        } else {
            System.debug('No updates needed for CRS_iFrame_URLs__c record "CRS_PaymentSourceUAT".');
        }

        // Update CRS_System_Settings__c records
        String systemSettingsEnv = getMappedEnvNameForSystemSettings(envName);
        // Update the "JNLPLocation" record
        CRS_System_Settings__c jnlpLocation = CRS_System_Settings__c.getValues('JNLPLocation');
        if (jnlpLocation == null) {
            throw new CustomException('CRS_System_Settings__c record with Name "JNLPLocation" not found.');
        }
        Boolean jnlpLocationNeedsUpdate = false;
        String expectedJnlpLocationUrl = 'jnlp:https://' + systemSettingsEnv + '.crsolympus.citigroup.net/CitiCiscoSoftPhone.jnlp';
        if (jnlpLocation.CRS_JNLP_Location__c != expectedJnlpLocationUrl) {
            System.debug('Updating CRS_JNLP_Location__c for "JNLPLocation" record. Current: ' + jnlpLocation.CRS_JNLP_Location__c + ', Expected: ' + expectedJnlpLocationUrl);
            jnlpLocation.CRS_JNLP_Location__c = expectedJnlpLocationUrl;
            jnlpLocationNeedsUpdate = true;
        } else {
            System.debug('CRS_JNLP_Location__c for "JNLPLocation" record is already correct: ' + jnlpLocation.CRS_JNLP_Location__c);
        }

        if (jnlpLocationNeedsUpdate) {
            update jnlpLocation;
            System.debug('Successfully updated CRS_System_Settings__c record "JNLPLocation".');
        } else {
            System.debug('No updates needed for CRS_System_Settings__c record "JNLPLocation".');
        }

        // Update the "RevokeOAuthAPI" record
        CRS_System_Settings__c revokeOAuth = CRS_System_Settings__c.getValues('RevokeOAuthAPI');
        if (revokeOAuth == null) {
            throw new CustomException('CRS_System_Settings__c record with Name "RevokeOAuthAPI" not found.');
        }
        Boolean revokeOAuthNeedsUpdate = false;
        String expectedRevokeOAuthUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + systemSettingsEnv + '/api/private/v2/digital/security/sso/revocation';
        if (revokeOAuth.Revoke_OAuth_API_URL__c != expectedRevokeOAuthUrl) {
            System.debug('Updating Revoke_OAuth_API_URL__c for "RevokeOAuthAPI" record. Current: ' + revokeOAuth.Revoke_OAuth_API_URL__c + ', Expected: ' + expectedRevokeOAuthUrl);
            revokeOAuth.Revoke_OAuth_API_URL__c = expectedRevokeOAuthUrl;
            revokeOAuthNeedsUpdate = true;
        } else {
            System.debug('Revoke_OAuth_API_URL__c for "RevokeOAuthAPI" record is already correct: ' + revokeOAuth.Revoke_OAuth_API_URL__c);
        }

        if (revokeOAuthNeedsUpdate) {
            update revokeOAuth;
            System.debug('Successfully updated CRS_System_Settings__c record "RevokeOAuthAPI".');
        } else {
            System.debug('No updates needed for CRS_System_Settings__c record "RevokeOAuthAPI".');
        }

        // Update the "LogoutCalloutUrl" record
        CRS_System_Settings__c logoutUrl = CRS_System_Settings__c.getValues('LogoutCalloutUrl');
        if (logoutUrl == null) {
            throw new CustomException('CRS_System_Settings__c record with Name "LogoutCalloutUrl" not found.');
        }
        Boolean logoutUrlNeedsUpdate = false;
        String expectedLogoutUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + systemSettingsEnv + '/api/private/v2/assistedAuth/sso';
        if (logoutUrl.Logout_API_URL__c != expectedLogoutUrl) {
            System.debug('Updating Logout_API_URL__c for "LogoutCalloutUrl" record. Current: ' + logoutUrl.Logout_API_URL__c + ', Expected: ' + expectedLogoutUrl);
            logoutUrl.Logout_API_URL__c = expectedLogoutUrl;
            logoutUrlNeedsUpdate = true;
        } else {
            System.debug('Logout_API_URL__c for "LogoutCalloutUrl" record is already correct: ' + logoutUrl.Logout_API_URL__c);
        }

        if (logoutUrlNeedsUpdate) {
            update logoutUrl;
            System.debug('Successfully updated CRS_System_Settings__c record "LogoutCalloutUrl".');
        } else {
            System.debug('No updates needed for CRS_System_Settings__c record "LogoutCalloutUrl".');
        }

        // Update CRS_Global_Auth_Headers__c records
        // Query for existing records to check client_id and targetApigeeHost values
        List<CRS_Global_Auth_Headers__c> authHeaders = [
            SELECT Id, CRS_Header_Name__c, CRS_Header_Value__c 
            FROM CRS_Global_Auth_Headers__c 
            WHERE CRS_Header_Name__c IN ('client_id', 'targetApigeeHost')
        ];
        if (authHeaders.isEmpty()) {
            throw new CustomException('No CRS_Global_Auth_Headers__c records found with CRS_Header_Name__c in (\'client_id\', \'targetApigeeHost\'). At least one record for each is expected.');
        }

        // Check and update client_id and targetApigeeHost values if necessary
        Boolean authHeadersNeedUpdate = false;
        for (CRS_Global_Auth_Headers__c header : authHeaders) {
            if (header.CRS_Header_Name__c == 'client_id') {
                if (header.CRS_Header_Value__c != expectedClientId) {
                    System.debug('Updating client_id in CRS_Global_Auth_Headers__c (Id: ' + header.Id + '). Current: ' + header.CRS_Header_Value__c + ', Expected: ' + expectedClientId);
                    header.CRS_Header_Value__c = expectedClientId;
                    authHeadersNeedUpdate = true;
                } else {
                    System.debug('client_id in CRS_Global_Auth_Headers__c (Id: ' + header.Id + ') is already correct: ' + header.CRS_Header_Value__c);
                }
            } else if (header.CRS_Header_Name__c == 'targetApigeeHost') {
                if (header.CRS_Header_Value__c != expectedApigeeHost) {
                    System.debug('Updating targetApigeeHost in CRS_Global_Auth_Headers__c (Id: ' + header.Id + '). Current: ' + header.CRS_Header_Value__c + ', Expected: ' + expectedApigeeHost);
                    header.CRS_Header_Value__c = expectedApigeeHost;
                    authHeadersNeedUpdate = true;
                } else {
                    System.debug('targetApigeeHost in CRS_Global_Auth_Headers__c (Id: ' + header.Id + ') is already correct: ' + header.CRS_Header_Value__c);
                }
            }
        }

        if (authHeadersNeedUpdate) {
            update authHeaders;
            System.debug('Successfully updated CRS_Global_Auth_Headers__c records.');
        } else {
            System.debug('No updates needed for CRS_Global_Auth_Headers__c records.');
        }

        // Update CRS_StaticValues__c records
        // Step 1: Query CRS_Integration_Headers__c to map CRS_Sub_URL__c to their Ids.
        // This is necessary because CRS_StaticValues__c records are linked to CRS_Integration_Headers__c records.
        List<CRS_Integration_Headers__c> integrationHeaders = [
            SELECT Id, CRS_Sub_URL__c 
            FROM CRS_Integration_Headers__c 
            WHERE CRS_Sub_URL__c IN (
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate',
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete',
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve'
            )
        ];
        // Expect 4 records: 2 for 'dueDate', 1 for 'delete', 1 for 'retrieve'
        if (integrationHeaders.size() != 4) { 
            throw new CustomException('Expected exactly 4 CRS_Integration_Headers__c records for the specified sub URLs, but found: ' + integrationHeaders.size());
        }

        // Map CRS_Sub_URL__c to a list of Ids, as 'dueDate' has two associated header records.
        Map<String, List<Id>> subUrlToHeaderIds = new Map<String, List<Id>>();
        for (CRS_Integration_Headers__c header : integrationHeaders) {
            if (!subUrlToHeaderIds.containsKey(header.CRS_Sub_URL__c)) {
                subUrlToHeaderIds.put(header.CRS_Sub_URL__c, new List<Id>());
            }
            subUrlToHeaderIds.get(header.CRS_Sub_URL__c).add(header.Id);
        }
        System.debug('Mapped CRS_Sub_URL__c to CRS_Integration_Headers__c Ids: ' + JSON.serialize(subUrlToHeaderIds));

        // Validate the number of header records found for each sub URL
        if (!subUrlToHeaderIds.containsKey('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate') || 
            subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate').size() != 2) {
            throw new CustomException('Expected exactly 2 CRS_Integration_Headers__c records for dueDate sub URL.');
        }
        if (!subUrlToHeaderIds.containsKey('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete') ||
            subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete').size() != 1) {
            throw new CustomException('Expected exactly 1 CRS_Integration_Headers__c record for dueDate/delete sub URL.');
        }
        if (!subUrlToHeaderIds.containsKey('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve') ||
            subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve').size() != 1) {
            throw new CustomException('Expected exactly 1 CRS_Integration_Headers__c record for dueDate/retrieve sub URL.');
        }

        // Step 2: Query existing CRS_StaticValues__c records linked to the relevant integration headers.
        List<CRS_StaticValues__c> existingStaticValues = [
            SELECT Id, Name, CRS_ParameterName__c, CRS_ParameterValue__c, CRS_Integration_Headers__c, CRS_Integration_Headers__r.CRS_Sub_URL__c
            FROM CRS_StaticValues__c
            WHERE CRS_Integration_Headers__r.CRS_Sub_URL__c IN :subUrlToHeaderIds.keySet()
        ];
        System.debug('Found ' + existingStaticValues.size() + ' existing CRS_StaticValues__c records for the relevant sub URLs.');

        // Step 3: Create a map of existing CRS_StaticValues__c records, keyed for easy lookup and comparison.
        // The key includes Name, ParameterName, SubUrl, and the Integration Header Id to ensure uniqueness.
        Map<String, CRS_StaticValues__c> existingRecordsByKey = new Map<String, CRS_StaticValues__c>();
        for (CRS_StaticValues__c record : existingStaticValues) {
            String key = record.Name + '|' + record.CRS_ParameterName__c + '|' + record.CRS_Integration_Headers__r.CRS_Sub_URL__c + '|' + record.CRS_Integration_Headers__c;
            existingRecordsByKey.put(key, record);
        }

        List<CRS_StaticValues__c> recordsToUpsert = new List<CRS_StaticValues__c>();
        List<CRS_StaticValues__c> recordsToDelete = new List<CRS_StaticValues__c>();
        Set<String> standardKeysFromProcessedRecords = new Set<String>(); // Tracks keys of standard records processed

        // Step 4: Process the defined STANDARD_STATIC_VALUES to determine inserts, updates, or if records are already correct.
        // This loop iterates through the standard configuration and compares it against existing records.
        Map<String, Integer> subUrlCounter = new Map<String, Integer>(); // Tracks usage of header Ids for 'dueDate'
        for (String subUrl : subUrlToHeaderIds.keySet()) {
            subUrlCounter.put(subUrl, 0);
        }

        for (StaticValueStandard standard : STANDARD_STATIC_VALUES) {
            String keyBase = standard.getKey(); // Generates key: name|parameterName|subUrl
            List<Id> headerIdsForSubUrl = subUrlToHeaderIds.get(standard.subUrl);
            if (headerIdsForSubUrl == null || headerIdsForSubUrl.isEmpty()) {
                // This should not happen due to earlier validation, but good for safety.
                throw new CustomException('No CRS_Integration_Headers__c records found for CRS_Sub_URL__c: ' + standard.subUrl + ' during standard processing.');
            }

            // Determine which CRS_Integration_Headers__c Id to use.
            // For 'dueDate', which has two header records, alternate between them for the two sets of 3 static values.
            Integer counter = subUrlCounter.get(standard.subUrl);
            Id headerIdToUse;
            if (standard.subUrl == '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate') {
                headerIdToUse = headerIdsForSubUrl.get(counter < 3 ? 0 : 1); // First 3 use first Id, next 3 use second Id
            } else {
                headerIdToUse = headerIdsForSubUrl.get(0); // Other subUrls have only one header record
            }

            String fullKey = keyBase + '|' + headerIdToUse;
            standardKeysFromProcessedRecords.add(fullKey);
            subUrlCounter.put(standard.subUrl, counter + 1); // Increment counter for the current subUrl

            CRS_StaticValues__c existingRecord = existingRecordsByKey.get(fullKey);
            if (existingRecord == null) {
                // Record does not exist, create a new one
                System.debug('Creating new CRS_StaticValues__c: ' + standard.name + '|' + standard.parameterName + ' for Header ID: ' + headerIdToUse);
                recordsToUpsert.add(new CRS_StaticValues__c(
                    Name = standard.name,
                    CRS_ParameterName__c = standard.parameterName,
                    CRS_ParameterValue__c = standard.parameterValue,
                    CRS_Integration_Headers__c = headerIdToUse
                ));
            } else {
                // Record exists, check if update is needed
                Boolean needsUpdate = false;
                if (existingRecord.CRS_ParameterValue__c != standard.parameterValue) {
                    System.debug('Updating CRS_ParameterValue__c for CRS_StaticValues__c (Id: ' + existingRecord.Id + '). Current: ' + existingRecord.CRS_ParameterValue__c + ', Expected: ' + standard.parameterValue);
                    existingRecord.CRS_ParameterValue__c = standard.parameterValue;
                    needsUpdate = true;
                }
                // It's unlikely CRS_Integration_Headers__c would change for an existing keyed record, 
                // but check for completeness.
                if (existingRecord.CRS_Integration_Headers__c != headerIdToUse) {
                     System.debug('Updating CRS_Integration_Headers__c for CRS_StaticValues__c (Id: ' + existingRecord.Id + '). Current: ' + existingRecord.CRS_Integration_Headers__c + ', Expected: ' + headerIdToUse);
                    existingRecord.CRS_Integration_Headers__c = headerIdToUse;
                    needsUpdate = true;
                }

                if (needsUpdate) {
                    recordsToUpsert.add(existingRecord);
                } else {
                    System.debug('CRS_StaticValues__c record (Id: ' + existingRecord.Id + ') with key (' +fullKey + ') is already correct.');
                }
            }
        }

        // Step 5: Identify existing records that are not part of the standard set and mark them for deletion.
        for (CRS_StaticValues__c existingRecord : existingRecordsByKey.values()) {
            String key = existingRecord.Name + '|' + existingRecord.CRS_ParameterName__c + '|' + existingRecord.CRS_Integration_Headers__r.CRS_Sub_URL__c + '|' + existingRecord.CRS_Integration_Headers__c;
            if (!standardKeysFromProcessedRecords.contains(key)) {
                System.debug('Deleting CRS_StaticValues__c (Id: ' + existingRecord.Id + ') with key ('+ key +') as it is not in the standard set.');
                recordsToDelete.add(existingRecord);
            }
        }

        // Step 6: Perform DML operations for upserts and deletes.
        if (!recordsToUpsert.isEmpty()) {
            upsert recordsToUpsert;
            System.debug('Successfully upserted ' + recordsToUpsert.size() + ' CRS_StaticValues__c records.');
        } else {
            System.debug('No CRS_StaticValues__c records needed upserting.');
        }

        if (!recordsToDelete.isEmpty()) {
            delete recordsToDelete;
            System.debug('Successfully deleted ' + recordsToDelete.size() + ' non-standard CRS_StaticValues__c records.');
        } else {
            System.debug('No non-standard CRS_StaticValues__c records found for deletion.');
        }

        // Update CRS_SSO_SAML_Mapping__mdt (Custom Metadata Type) record
        // Step 1: Query the specific CRS_SSO_SAML_Mapping__mdt record with DeveloperName = 'username'.
        System.debug('Querying CRS_SSO_SAML_Mapping__mdt for DeveloperName = \'username\'.');
        List<CRS_SSO_SAML_Mapping__mdt> samlMappings = [
            SELECT DeveloperName, CRS_SandBox_Name__c, CRS_Is_SandBox__c, CRS_Saml_Val__c, CRS_SF_Val__c
            FROM CRS_SSO_SAML_Mapping__mdt
            WHERE DeveloperName = 'username'
            LIMIT 1
        ];
        
        // Step 2: Validate that exactly one record is found.
        if (samlMappings.isEmpty()) {
            throw new CustomException('No CRS_SSO_SAML_Mapping__mdt record found with DeveloperName = \'username\'.');
        }
        System.debug('Found CRS_SSO_SAML_Mapping__mdt record: ' + samlMappings[0].DeveloperName);
        
        // Step 3: Prepare and execute the Metadata API update.
        // This is required for updating Custom Metadata Type records.
        try {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId(); // Use current user's session
        
            // Construct the Custom Metadata record for the update operation
            MetadataService.CustomMetadata customMetadata = new MetadataService.CustomMetadata();
            customMetadata.fullName = 'CRS_SSO_SAML_Mapping__mdt.' + samlMappings[0].DeveloperName; // Target specific record
            customMetadata.label = samlMappings[0].DeveloperName; // Label must be provided
        
            // Define the field values to update
            MetadataService.CustomMetadataValue sandboxNameValue = new MetadataService.CustomMetadataValue();
            sandboxNameValue.field = 'CRS_SandBox_Name__c';
            sandboxNameValue.value = sandboxName; // Value from SandboxEnvironmetConfig__c
            System.debug('Setting CRS_SandBox_Name__c in metadata to: ' + sandboxName);
        
            MetadataService.CustomMetadataValue isSandboxValue = new MetadataService.CustomMetadataValue();
            isSandboxValue.field = 'CRS_Is_SandBox__c';
            isSandboxValue.value = 'TRUE'; // Hardcoded as per requirements
            System.debug('Setting CRS_Is_SandBox__c in metadata to: TRUE');
        
            MetadataService.CustomMetadataValue samlValValue = new MetadataService.CustomMetadataValue();
            samlValValue.field = 'CRS_Saml_Val__c';
            samlValValue.value = 'email'; // Hardcoded as per requirements
            System.debug('Setting CRS_Saml_Val__c in metadata to: email');
        
            MetadataService.CustomMetadataValue sfValValue = new MetadataService.CustomMetadataValue();
            sfValValue.field = 'CRS_SF_Val__c';
            sfValValue.value = 'username'; // Hardcoded as per requirements
            System.debug('Setting CRS_SF_Val__c in metadata to: username');
        
            customMetadata.values = new MetadataService.CustomMetadataValue[] {
                sandboxNameValue, isSandboxValue, samlValValue, sfValValue
            };
        
            // Step 4: Perform the Metadata API upsert operation.
            System.debug('Initiating Metadata API upsert for CRS_SSO_SAML_Mapping__mdt record: ' + customMetadata.fullName);
            MetadataService.Metadata[] metadataToUpdate = new MetadataService.Metadata[] { customMetadata };
            MetadataService.UpsertResult[] results = service.upsertMetadata(metadataToUpdate);
        
            // Step 5: Check the result of the Metadata API operation.
            for (MetadataService.UpsertResult result : results) {
                if (!result.success) {
                    String errorMessage = 'Failed to update CRS_SSO_SAML_Mapping__mdt record "' + result.fullName + '": ';
                    for (MetadataService.Error error : result.errors) {
                        errorMessage += error.statusCode + ': ' + error.message + ' (Fields: ' + String.join(error.fields, ', ') + '); ';
                    }
                    throw new CustomException(errorMessage);
                } else {
                    System.debug('Successfully updated CRS_SSO_SAML_Mapping__mdt record: ' + result.fullName);
                }
            }
        } catch (Exception e) {
            System.debug('Exception during CRS_SSO_SAML_Mapping__mdt update: ' + e.getTypeName() + ': ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
            throw new CustomException('Failed to update CRS_SSO_SAML_Mapping__mdt due to: ' + e.getMessage());
        }
    }

    /**
     * @description Custom exception class for consistent error handling within this class.
     */
    public class CustomException extends Exception {}
}
