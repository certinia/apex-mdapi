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
 * @description Apex class to update sandbox configuration settings based on the environment name.
 *              Updates Custom Settings, CRS_Global_Auth_Headers__c, CRS_StaticValues__c, and CRS_SSO_SAML_Mapping__mdt with environment-specific values.
 */
public class SandboxConfigUpdater {

    // Map of environment names to client_id values
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

    // Define the standard set of CRS_StaticValues__c records
    private static final List<StaticValueStandard> STANDARD_STATIC_VALUES = new List<StaticValueStandard> {
        // Sub URL: /api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate (6 records, to be split across 2 CRS_Integration_Headers__c records)
        // First set of 3 records for the first CRS_Integration_Headers__c record
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        // Second set of 3 records for the second CRS_Integration_Headers__c record
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate'),
        // Sub URL: /api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete (3 records)
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete'),
        // Sub URL: /api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve (3 records)
        new StaticValueStandard('uuid', 'uuid', '7dc53df5-703e-49b3-8670-b1c468f47f1f', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve'),
        new StaticValueStandard('sourceApplicationId', 'sourceApplicationId', 'SALESFORCE', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve'),
        new StaticValueStandard('preferredLanguageCode', 'preferredLanguageCode', 'en', '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve')
    };

    /**
     * @description Maps the environment name for CRS_Call_Recording_Settings__c URLs based on specific rules.
     * @param envName The original environment name.
     * @return The mapped environment name to use in URLs.
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
     * @description Maps the environment name for CRS_iFrame_URLs__c URLs based on specific rules.
     * @param envName The original environment name.
     * @return The mapped environment name to use in URLs.
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
     * @description Maps the environment name for CRS_System_Settings__c URLs based on specific rules.
     * @param envName The original environment name.
     * @return The mapped environment name to use in URLs.
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
     * @description Updates various Custom Settings, CRS_Global_Auth_Headers__c, CRS_StaticValues__c, and CRS_SSO_SAML_Mapping__mdt with values based on the environment name.
     *              Retrieves the environment name from SandboxEnvironmetConfig__c and applies it to other settings.
     * @throws CustomException if required Custom Setting records are missing or invalid, or if Metadata API updates fail.
     */
    public static void updateSettings() {
        // Retrieve the environment name and sandbox name from SandboxEnvironmetConfig__c (Hierarchy Custom Setting)
        SandboxEnvironmetConfig__c config = SandboxEnvironmetConfig__c.getOrgDefaults();
        if (config == null || String.isBlank(config.EnvironmentName__c)) {
            throw new CustomException('Custom Setting "SandboxEnvironmetConfig" with name "Default" not found or EnvironmentName__c is blank.');
        }
        String envName = config.EnvironmentName__c.toLowerCase();
        System.debug('Retrieved EnvironmentName__c: ' + envName);

        // Retrieve the Sandbox_Name__c value for use in CRS_SSO_SAML_Mapping__mdt update
        String sandboxName = config.Sandbox_Name__c;
        if (String.isBlank(sandboxName)) {
            throw new CustomException('Sandbox_Name__c is blank in SandboxEnvironmetConfig__c for environment: ' + envName);
        }
        System.debug('Retrieved Sandbox_Name__c: ' + sandboxName);

        // Map the sandbox environment name to the standard environment name
        String standardEnv = SANDBOX_ENV_TO_STANDARD_ENV.get(envName);
        if (standardEnv == null) {
            throw new CustomException('Environment name "' + envName + '" not recognized. Expected values: ' + SANDBOX_ENV_TO_STANDARD_ENV.keySet());
        }
        System.debug('Mapped sandbox environment "' + envName + '" to standard environment "' + standardEnv + '"');

        // Get the expected client_id value for the environment
        String expectedClientId = ENV_TO_CLIENT_ID.get(standardEnv);
        if (expectedClientId == null) {
            throw new CustomException('No client_id value found for environment "' + standardEnv + '".');
        }
        System.debug('Expected client_id for environment "' + standardEnv + '": ' + expectedClientId);

        // Construct the expected targetApigeeHost value for the environment
        String expectedApigeeHost = envName + '.secure2.assistedchannel.nam.pbwm.citigroup.net';
        System.debug('Expected targetApigeeHost for environment "' + envName + '": ' + expectedApigeeHost);

        // --- Update CRS_Call_Recording_Settings__c ---
        String callRecordingEnv = getMappedEnvNameForCallRecording(envName);
        // Update the CallRecordingDetails record with environment-specific URLs
        CRS_Call_Recording_Settings__c callRecordingDetails = CRS_Call_Recording_Settings__c.getValues('CallRecordingDetails');
        if (callRecordingDetails == null) {
            throw new CustomException('CRS_Call_Recording_Settings__c record "CallRecordingDetails" not found.');
        }
        Boolean callRecordingDetailsNeedsUpdate = false;
        String expectedLoadBalancingUrl = 'B178542-vip.nam.nsroot.net';
        String expectedRsiClientUrl = 'https://ast-svc-v-voicecallrecordingweb-sw1' + callRecordingEnv + '.apps-sw1-dev.nam.nsroot.net/rsi/recording-system/index';
        String expectedStopRecordingUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + callRecordingEnv + '/api/private/v1/callRecording/termination';
        String expectedUpdateBusinessDataUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + callRecordingEnv + '/api/private/v1/callRecording/businessData';

        if (callRecordingDetails.CRS_Load_Balancing_URL__c != expectedLoadBalancingUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + '). Current CRS_Load_Balancing_URL__c: ' + 
                         callRecordingDetails.CRS_Load_Balancing_URL__c + ', Expected: ' + expectedLoadBalancingUrl);
            callRecordingDetails.CRS_Load_Balancing_URL__c = expectedLoadBalancingUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + ') already has the correct CRS_Load_Balancing_URL__c: ' + 
                         callRecordingDetails.CRS_Load_Balancing_URL__c);
        }
        if (callRecordingDetails.CRS_RSI_Client_URL__c != expectedRsiClientUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + '). Current CRS_RSI_Client_URL__c: ' + 
                         callRecordingDetails.CRS_RSI_Client_URL__c + ', Expected: ' + expectedRsiClientUrl);
            callRecordingDetails.CRS_RSI_Client_URL__c = expectedRsiClientUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + ') already has the correct CRS_RSI_Client_URL__c: ' + 
                         callRecordingDetails.CRS_RSI_Client_URL__c);
        }
        if (callRecordingDetails.CRS_Stop_Recording_URL__c != expectedStopRecordingUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + '). Current CRS_Stop_Recording_URL__c: ' + 
                         callRecordingDetails.CRS_Stop_Recording_URL__c + ', Expected: ' + expectedStopRecordingUrl);
            callRecordingDetails.CRS_Stop_Recording_URL__c = expectedStopRecordingUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + ') already has the correct CRS_Stop_Recording_URL__c: ' + 
                         callRecordingDetails.CRS_Stop_Recording_URL__c);
        }
        if (callRecordingDetails.CRS_Update_Business_Data_URL__c != expectedUpdateBusinessDataUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + '). Current CRS_Update_Business_Data_URL__c: ' + 
                         callRecordingDetails.CRS_Update_Business_Data_URL__c + ', Expected: ' + expectedUpdateBusinessDataUrl);
            callRecordingDetails.CRS_Update_Business_Data_URL__c = expectedUpdateBusinessDataUrl;
            callRecordingDetailsNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails" (Id: ' + callRecordingDetails.Id + ') already has the correct CRS_Update_Business_Data_URL__c: ' + 
                         callRecordingDetails.CRS_Update_Business_Data_URL__c);
        }
        if (callRecordingDetailsNeedsUpdate) {
            update callRecordingDetails;
            System.debug('Successfully updated CRS_Call_Recording_Settings__c record "CallRecordingDetails" with CRS_Load_Balancing_URL__c: ' + expectedLoadBalancingUrl + 
                         ', CRS_RSI_Client_URL__c: ' + expectedRsiClientUrl + ', CRS_Stop_Recording_URL__c: ' + expectedStopRecordingUrl + 
                         ', CRS_Update_Business_Data_URL__c: ' + expectedUpdateBusinessDataUrl);
        } else {
            System.debug('No updates needed for CRS_Call_Recording_Settings__c record "CallRecordingDetails".');
        }

        // Update the CallRecordingDetails_SW record with the same environment-specific URLs
        CRS_Call_Recording_Settings__c callRecordingDetailsSW = CRS_Call_Recording_Settings__c.getValues('CallRecordingDetails_SW');
        if (callRecordingDetailsSW == null) {
            throw new CustomException('CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" not found.');
        }
        Boolean callRecordingDetailsSWNeedsUpdate = false;
        if (callRecordingDetailsSW.CRS_Load_Balancing_URL__c != expectedLoadBalancingUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + '). Current CRS_Load_Balancing_URL__c: ' + 
                         callRecordingDetailsSW.CRS_Load_Balancing_URL__c + ', Expected: ' + expectedLoadBalancingUrl);
            callRecordingDetailsSW.CRS_Load_Balancing_URL__c = expectedLoadBalancingUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + ') already has the correct CRS_Load_Balancing_URL__c: ' + 
                         callRecordingDetailsSW.CRS_Load_Balancing_URL__c);
        }
        if (callRecordingDetailsSW.CRS_RSI_Client_URL__c != expectedRsiClientUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + '). Current CRS_RSI_Client_URL__c: ' + 
                         callRecordingDetailsSW.CRS_RSI_Client_URL__c + ', Expected: ' + expectedRsiClientUrl);
            callRecordingDetailsSW.CRS_RSI_Client_URL__c = expectedRsiClientUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + ') already has the correct CRS_RSI_Client_URL__c: ' + 
                         callRecordingDetailsSW.CRS_RSI_Client_URL__c);
        }
        if (callRecordingDetailsSW.CRS_Stop_Recording_URL__c != expectedStopRecordingUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + '). Current CRS_Stop_Recording_URL__c: ' + 
                         callRecordingDetailsSW.CRS_Stop_Recording_URL__c + ', Expected: ' + expectedStopRecordingUrl);
            callRecordingDetailsSW.CRS_Stop_Recording_URL__c = expectedStopRecordingUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + ') already has the correct CRS_Stop_Recording_URL__c: ' + 
                         callRecordingDetailsSW.CRS_Stop_Recording_URL__c);
        }
        if (callRecordingDetailsSW.CRS_Update_Business_Data_URL__c != expectedUpdateBusinessDataUrl) {
            System.debug('Updating CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + '). Current CRS_Update_Business_Data_URL__c: ' + 
                         callRecordingDetailsSW.CRS_Update_Business_Data_URL__c + ', Expected: ' + expectedUpdateBusinessDataUrl);
            callRecordingDetailsSW.CRS_Update_Business_Data_URL__c = expectedUpdateBusinessDataUrl;
            callRecordingDetailsSWNeedsUpdate = true;
        } else {
            System.debug('CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" (Id: ' + callRecordingDetailsSW.Id + ') already has the correct CRS_Update_Business_Data_URL__c: ' + 
                         callRecordingDetailsSW.CRS_Update_Business_Data_URL__c);
        }
        if (callRecordingDetailsSWNeedsUpdate) {
            update callRecordingDetailsSW;
            System.debug('Successfully updated CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW" with CRS_Load_Balancing_URL__c: ' + expectedLoadBalancingUrl + 
                         ', CRS_RSI_Client_URL__c: ' + expectedRsiClientUrl + ', CRS_Stop_Recording_URL__c: ' + expectedStopRecordingUrl + 
                         ', CRS_Update_Business_Data_URL__c: ' + expectedUpdateBusinessDataUrl);
        } else {
            System.debug('No updates needed for CRS_Call_Recording_Settings__c record "CallRecordingDetails_SW".');
        }

        // --- Update CRS_iFrame_URLs__c ---
        String iframeEnv = getMappedEnvNameForIframeUrls(envName);
        // Update the CRS_PaymentOriginUAT record with the payment origin URL
        CRS_iFrame_URLs__c paymentOrigin = CRS_iFrame_URLs__c.getValues('CRS_PaymentOriginUAT');
        if (paymentOrigin == null) {
            throw new CustomException('CRS_iFrame_URLs__c record "CRS_PaymentOriginUAT" not found.');
        }
        Boolean paymentOriginNeedsUpdate = false;
        String expectedPaymentOriginUrl = 'https://' + iframeEnv + '.payment.citiretailservices.citigroup.net';
        if (paymentOrigin.iFrame_URL__c != expectedPaymentOriginUrl) {
            System.debug('Updating CRS_iFrame_URLs__c record "CRS_PaymentOriginUAT" (Id: ' + paymentOrigin.Id + '). Current iFrame_URL__c: ' + 
                         paymentOrigin.iFrame_URL__c + ', Expected: ' + expectedPaymentOriginUrl);
            paymentOrigin.iFrame_URL__c = expectedPaymentOriginUrl;
            paymentOriginNeedsUpdate = true;
        } else {
            System.debug('CRS_iFrame_URLs__c record "CRS_PaymentOriginUAT" (Id: ' + paymentOrigin.Id + ') already has the correct iFrame_URL__c: ' + 
                         paymentOrigin.iFrame_URL__c);
        }
        if (paymentOriginNeedsUpdate) {
            update paymentOrigin;
            System.debug('Successfully updated CRS_iFrame_URLs__c record "CRS_PaymentOriginUAT" with iFrame_URL__c: ' + expectedPaymentOriginUrl);
        } else {
            System.debug('No updates needed for CRS_iFrame_URLs__c record "CRS_PaymentOriginUAT".');
        }

        // Update the CRS_PaymentSourceUAT record with the payment source URL
        CRS_iFrame_URLs__c paymentSource = CRS_iFrame_URLs__c.getValues('CRS_PaymentSourceUAT');
        if (paymentSource == null) {
            throw new CustomException('CRS_iFrame_URLs__c record "CRS_PaymentSourceUAT" not found.');
        }
        Boolean paymentSourceNeedsUpdate = false;
        String expectedPaymentSourceUrl = 'https://' + iframeEnv + '.payment.citiretailservices.citigroup.net/contact-center?pageName=payments&siteId=app_rplid&appName=olympus';
        if (paymentSource.iFrame_URL__c != expectedPaymentSourceUrl) {
            System.debug('Updating CRS_iFrame_URLs__c record "CRS_PaymentSourceUAT" (Id: ' + paymentSource.Id + '). Current iFrame_URL__c: ' + 
                         paymentSource.iFrame_URL__c + ', Expected: ' + expectedPaymentSourceUrl);
            paymentSource.iFrame_URL__c = expectedPaymentSourceUrl;
            paymentSourceNeedsUpdate = true;
        } else {
            System.debug('CRS_iFrame_URLs__c record "CRS_PaymentSourceUAT" (Id: ' + paymentSource.Id + ') already has the correct iFrame_URL__c: ' + 
                         paymentSource.iFrame_URL__c);
        }
        if (paymentSourceNeedsUpdate) {
            update paymentSource;
            System.debug('Successfully updated CRS_iFrame_URLs__c record "CRS_PaymentSourceUAT" with iFrame_URL__c: ' + expectedPaymentSourceUrl);
        } else {
            System.debug('No updates needed for CRS_iFrame_URLs__c record "CRS_PaymentSourceUAT".');
        }

        // --- Update CRS_System_Settings__c ---
        String systemSettingsEnv = getMappedEnvNameForSystemSettings(envName);
        // Update the JNLPLocation record with the JNLP location URL
        CRS_System_Settings__c jnlpLocation = CRS_System_Settings__c.getValues('JNLPLocation');
        if (jnlpLocation == null) {
            throw new CustomException('CRS_System_Settings__c record "JNLPLocation" not found.');
        }
        Boolean jnlpLocationNeedsUpdate = false;
        String expectedJnlpLocationUrl = 'jnlp:https://' + systemSettingsEnv + '.crsolympus.citigroup.net/CitiCiscoSoftPhone.jnlp';
        if (jnlpLocation.CRS_JNLP_Location__c != expectedJnlpLocationUrl) {
            System.debug('Updating CRS_System_Settings__c record "JNLPLocation" (Id: ' + jnlpLocation.Id + '). Current CRS_JNLP_Location__c: ' + 
                         jnlpLocation.CRS_JNLP_Location__c + ', Expected: ' + expectedJnlpLocationUrl);
            jnlpLocation.CRS_JNLP_Location__c = expectedJnlpLocationUrl;
            jnlpLocationNeedsUpdate = true;
        } else {
            System.debug('CRS_System_Settings__c record "JNLPLocation" (Id: ' + jnlpLocation.Id + ') already has the correct CRS_JNLP_Location__c: ' + 
                         jnlpLocation.CRS_JNLP_Location__c);
        }
        if (jnlpLocationNeedsUpdate) {
            update jnlpLocation;
            System.debug('Successfully updated CRS_System_Settings__c record "JNLPLocation" with CRS_JNLP_Location__c: ' + expectedJnlpLocationUrl);
        } else {
            System.debug('No updates needed for CRS_System_Settings__c record "JNLPLocation".');
        }

        // Update the RevokeOAuthAPI record with the OAuth revocation URL
        CRS_System_Settings__c revokeOAuth = CRS_System_Settings__c.getValues('RevokeOAuthAPI');
        if (revokeOAuth == null) {
            throw new CustomException('CRS_System_Settings__c record "RevokeOAuthAPI" not found.');
        }
        Boolean revokeOAuthNeedsUpdate = false;
        String expectedRevokeOAuthUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + systemSettingsEnv + '/api/private/v2/digital/security/sso/revocation';
        if (revokeOAuth.Revoke_OAuth_API_URL__c != expectedRevokeOAuthUrl) {
            System.debug('Updating CRS_System_Settings__c record "RevokeOAuthAPI" (Id: ' + revokeOAuth.Id + '). Current Revoke_OAuth_API_URL__c: ' + 
                         revokeOAuth.Revoke_OAuth_API_URL__c + ', Expected: ' + expectedRevokeOAuthUrl);
            revokeOAuth.Revoke_OAuth_API_URL__c = expectedRevokeOAuthUrl;
            revokeOAuthNeedsUpdate = true;
        } else {
            System.debug('CRS_System_Settings__c record "RevokeOAuthAPI" (Id: ' + revokeOAuth.Id + ') already has the correct Revoke_OAuth_API_URL__c: ' + 
                         revokeOAuth.Revoke_OAuth_API_URL__c);
        }
        if (revokeOAuthNeedsUpdate) {
            update revokeOAuth;
            System.debug('Successfully updated CRS_System_Settings__c record "RevokeOAuthAPI" with Revoke_OAuth_API_URL__c: ' + expectedRevokeOAuthUrl);
        } else {
            System.debug('No updates needed for CRS_System_Settings__c record "RevokeOAuthAPI".');
        }

        // Update the LogoutCalloutUrl record with the logout API URL
        CRS_System_Settings__c logoutUrl = CRS_System_Settings__c.getValues('LogoutCalloutUrl');
        if (logoutUrl == null) {
            throw new CustomException('CRS_System_Settings__c record "LogoutCalloutUrl" not found.');
        }
        Boolean logoutUrlNeedsUpdate = false;
        String expectedLogoutUrl = 'https://crsolympus.sandbox.apib2b.citi.com/olympus/' + systemSettingsEnv + '/api/private/v2/assistedAuth/sso';
        if (logoutUrl.Logout_API_URL__c != expectedLogoutUrl) {
            System.debug('Updating CRS_System_Settings__c record "LogoutCalloutUrl" (Id: ' + logoutUrl.Id + '). Current Logout_API_URL__c: ' + 
                         logoutUrl.Logout_API_URL__c + ', Expected: ' + expectedLogoutUrl);
            logoutUrl.Logout_API_URL__c = expectedLogoutUrl;
            logoutUrlNeedsUpdate = true;
        } else {
            System.debug('CRS_System_Settings__c record "LogoutCalloutUrl" (Id: ' + logoutUrl.Id + ') already has the correct Logout_API_URL__c: ' + 
                         logoutUrl.Logout_API_URL__c);
        }
        if (logoutUrlNeedsUpdate) {
            update logoutUrl;
            System.debug('Successfully updated CRS_System_Settings__c record "LogoutCalloutUrl" with Logout_API_URL__c: ' + expectedLogoutUrl);
        } else {
            System.debug('No updates needed for CRS_System_Settings__c record "LogoutCalloutUrl".');
        }

        // --- Update CRS_Global_Auth_Headers__c ---
        // Query for records to check client_id and targetApigeeHost values
        List<CRS_Global_Auth_Headers__c> authHeaders = [
            SELECT Id, CRS_Header_Name__c, CRS_Header_Value__c 
            FROM CRS_Global_Auth_Headers__c 
            WHERE CRS_Header_Name__c IN ('client_id', 'targetApigeeHost')
        ];
        if (authHeaders.isEmpty()) {
            throw new CustomException('No CRS_Global_Auth_Headers__c records found with CRS_Header_Name__c in ("client_id", "targetApigeeHost").');
        }

        // Check and update the client_id and targetApigeeHost values if necessary
        Boolean needsUpdate = false;
        for (CRS_Global_Auth_Headers__c header : authHeaders) {
            if (header.CRS_Header_Name__c == 'client_id') {
                if (header.CRS_Header_Value__c != expectedClientId) {
                    System.debug('Updating CRS_Global_Auth_Headers__c record (Id: ' + header.Id + '). Current client_id: ' + 
                                 header.CRS_Header_Value__c + ', Expected: ' + expectedClientId);
                    header.CRS_Header_Value__c = expectedClientId;
                    needsUpdate = true;
                } else {
                    System.debug('CRS_Global_Auth_Headers__c record (Id: ' + header.Id + ') already has the correct client_id: ' + 
                                 header.CRS_Header_Value__c);
                }
            } else if (header.CRS_Header_Name__c == 'targetApigeeHost') {
                if (header.CRS_Header_Value__c != expectedApigeeHost) {
                    System.debug('Updating CRS_Global_Auth_Headers__c record (Id: ' + header.Id + '). Current targetApigeeHost: ' + 
                                 header.CRS_Header_Value__c + ', Expected: ' + expectedApigeeHost);
                    header.CRS_Header_Value__c = expectedApigeeHost;
                    needsUpdate = true;
                } else {
                    System.debug('CRS_Global_Auth_Headers__c record (Id: ' + header.Id + ') already has the correct targetApigeeHost: ' + 
                                 header.CRS_Header_Value__c);
                }
            }
        }

        // Perform the update if any records were modified
        if (needsUpdate) {
            update authHeaders;
            System.debug('Successfully updated CRS_Global_Auth_Headers__c records with client_id: ' + expectedClientId + 
                         ' and targetApigeeHost: ' + expectedApigeeHost);
        } else {
            System.debug('No updates needed for CRS_Global_Auth_Headers__c records.');
        }

        // --- Update CRS_StaticValues__c ---
        // Step 1: Query CRS_Integration_Headers__c to map CRS_Sub_URL__c to Ids
        List<CRS_Integration_Headers__c> integrationHeaders = [
            SELECT Id, CRS_Sub_URL__c 
            FROM CRS_Integration_Headers__c 
            WHERE CRS_Sub_URL__c IN (
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate',
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete',
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve'
            )
        ];
        if (integrationHeaders.size() != 4) {
            throw new CustomException('Expected exactly 4 CRS_Integration_Headers__c records (2 for dueDate, 1 for delete, 1 for retrieve), but found: ' + integrationHeaders.size());
        }

        // Map CRS_Sub_URL__c to a list of Ids (since dueDate has 2 records)
        Map<String, List<Id>> subUrlToHeaderIds = new Map<String, List<Id>>();
        for (CRS_Integration_Headers__c header : integrationHeaders) {
            if (!subUrlToHeaderIds.containsKey(header.CRS_Sub_URL__c)) {
                subUrlToHeaderIds.put(header.CRS_Sub_URL__c, new List<Id>());
            }
            subUrlToHeaderIds.get(header.CRS_Sub_URL__c).add(header.Id);
        }
        System.debug('Mapped CRS_Sub_URL__c to CRS_Integration_Headers__c Ids: ' + subUrlToHeaderIds);

        // Validate the number of records for each CRS_Sub_URL__c
        if (subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate').size() != 2) {
            throw new CustomException('Expected exactly 2 CRS_Integration_Headers__c records for CRS_Sub_URL__c "/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate", but found: ' + 
                                      subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate').size());
        }
        if (subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete').size() != 1) {
            throw new CustomException('Expected exactly 1 CRS_Integration_Headers__c record for CRS_Sub_URL__c "/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete", but found: ' + 
                                      subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete').size());
        }
        if (subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve').size() != 1) {
            throw new CustomException('Expected exactly 1 CRS_Integration_Headers__c record for CRS_Sub_URL__c "/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve", but found: ' + 
                                      subUrlToHeaderIds.get('/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve').size());
        }

        // Step 2: Query existing CRS_StaticValues__c records
        List<CRS_StaticValues__c> existingStaticValues = [
            SELECT Id, Name, CRS_ParameterName__c, CRS_ParameterValue__c, CRS_Integration_Headers__c, CRS_Integration_Headers__r.CRS_Sub_URL__c
            FROM CRS_StaticValues__c
            WHERE CRS_Integration_Headers__r.CRS_Sub_URL__c IN (
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate',
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/delete',
                '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate/retrieve'
            )
        ];
        System.debug('Found ' + existingStaticValues.size() + ' existing CRS_StaticValues__c records.');

        // Step 3: Compare existing records with the standard set
        Map<String, CRS_StaticValues__c> existingRecordsByKey = new Map<String, CRS_StaticValues__c>();
        for (CRS_StaticValues__c record : existingStaticValues) {
            String key = record.Name + '|' + record.CRS_ParameterName__c + '|' + record.CRS_Integration_Headers__r.CRS_Sub_URL__c + '|' + record.CRS_Integration_Headers__c;
            existingRecordsByKey.put(key, record);
        }

        List<CRS_StaticValues__c> recordsToUpsert = new List<CRS_StaticValues__c>();
        List<CRS_StaticValues__c> recordsToDelete = new List<CRS_StaticValues__c>();
        Set<String> standardKeys = new Set<String>();

        // Step 4: Process standard records
        // Track which header Id to use for dueDate records (alternate between the two)
        Map<String, Integer> subUrlCounter = new Map<String, Integer>();
        for (String subUrl : subUrlToHeaderIds.keySet()) {
            subUrlCounter.put(subUrl, 0);
        }

        for (StaticValueStandard standard : STANDARD_STATIC_VALUES) {
            String keyBase = standard.getKey(); // name|parameterName|subUrl
            List<Id> headerIds = subUrlToHeaderIds.get(standard.subUrl);
            if (headerIds == null || headerIds.isEmpty()) {
                throw new CustomException('No CRS_Integration_Headers__c records found for CRS_Sub_URL__c: ' + standard.subUrl);
            }

            // Determine which header Id to use
            Integer counter = subUrlCounter.get(standard.subUrl);
            Id headerId;
            if (standard.subUrl == '/api/private/v1/microapp/bpm/retailCards/moneyMovement/payments/dueDate') {
                // For dueDate, alternate between the two header Ids
                // First 3 records (uuid, sourceApplicationId, preferredLanguageCode) use the first Id
                // Next 3 records use the second Id
                headerId = headerIds.get(counter < 3 ? 0 : 1);
            } else {
                // For delete and retrieve, there's only one header Id
                headerId = headerIds.get(0);
            }

            String key = keyBase + '|' + headerId;
            standardKeys.add(key);

            // Update the counter
            subUrlCounter.put(standard.subUrl, counter + 1);

            CRS_StaticValues__c existingRecord = existingRecordsByKey.get(key);
            if (existingRecord == null) {
                // New record to insert
                System.debug('Creating new CRS_StaticValues__c record with Name: ' + standard.name + ', CRS_ParameterName__c: ' + standard.parameterName + 
                             ', CRS_ParameterValue__c: ' + standard.parameterValue + ', CRS_Integration_Headers__c: ' + headerId);
                CRS_StaticValues__c newRecord = new CRS_StaticValues__c(
                    Name = standard.name,
                    CRS_ParameterName__c = standard.parameterName,
                    CRS_ParameterValue__c = standard.parameterValue,
                    CRS_Integration_Headers__c = headerId
                );
                recordsToUpsert.add(newRecord);
            } else {
                // Check if update is needed
                Boolean needsStaticValueUpdate = false;
                if (existingRecord.CRS_ParameterValue__c != standard.parameterValue) {
                    System.debug('Updating CRS_StaticValues__c record (Id: ' + existingRecord.Id + '). Current CRS_ParameterValue__c: ' + 
                                 existingRecord.CRS_ParameterValue__c + ', Expected: ' + standard.parameterValue);
                    existingRecord.CRS_ParameterValue__c = standard.parameterValue;
                    needsStaticValueUpdate = true;
                }
                if (existingRecord.CRS_Integration_Headers__c != headerId) {
                    System.debug('Updating CRS_StaticValues__c record (Id: ' + existingRecord.Id + '). Current CRS_Integration_Headers__c: ' + 
                                 existingRecord.CRS_Integration_Headers__c + ', Expected: ' + headerId);
                    existingRecord.CRS_Integration_Headers__c = headerId;
                    needsStaticValueUpdate = true;
                }
                if (needsStaticValueUpdate) {
                    recordsToUpsert.add(existingRecord);
                } else {
                    System.debug('CRS_StaticValues__c record (Id: ' + existingRecord.Id + ') already has the correct values: Name: ' + existingRecord.Name + 
                                 ', CRS_ParameterName__c: ' + existingRecord.CRS_ParameterName__c + ', CRS_ParameterValue__c: ' + existingRecord.CRS_ParameterValue__c);
                }
            }
        }

        // Step 5: Identify records to delete (existing records not in the standard set)
        for (CRS_StaticValues__c existingRecord : existingRecordsByKey.values()) {
            String key = existingRecord.Name + '|' + existingRecord.CRS_ParameterName__c + '|' + existingRecord.CRS_Integration_Headers__r.CRS_Sub_URL__c + '|' + existingRecord.CRS_Integration_Headers__c;
            if (!standardKeys.contains(key)) {
                System.debug('Deleting CRS_StaticValues__c record (Id: ' + existingRecord.Id + ') as it is not in the standard set: Name: ' + existingRecord.Name + 
                             ', CRS_ParameterName__c: ' + existingRecord.CRS_ParameterName__c + ', CRS_ParameterValue__c: ' + existingRecord.CRS_ParameterValue__c);
                recordsToDelete.add(existingRecord);
            }
        }

        // Step 6: Perform DML operations
        if (!recordsToUpsert.isEmpty()) {
            upsert recordsToUpsert;
            System.debug('Successfully upserted ' + recordsToUpsert.size() + ' CRS_StaticValues__c records.');
        } else {
            System.debug('No CRS_StaticValues__c records needed to be upserted.');
        }

        if (!recordsToDelete.isEmpty()) {
            delete recordsToDelete;
            System.debug('Successfully deleted ' + recordsToDelete.size() + ' CRS_StaticValues__c records that were not in the standard set.');
        } else {
            System.debug('No CRS_StaticValues__c records needed to be deleted.');
        }

        // --- Update CRS_SSO_SAML_Mapping__mdt ---
        // Step 1: Query the CRS_SSO_SAML_Mapping__mdt record with DeveloperName = 'username'
        System.debug('Querying CRS_SSO_SAML_Mapping__mdt for DeveloperName = "username"');
        List<CRS_SSO_SAML_Mapping__mdt> samlMappings = [
            SELECT DeveloperName, CRS_SandBox_Name__c, CRS_Is_SandBox__c, CRS_Saml_Val__c, CRS_SF_Val__c
            FROM CRS_SSO_SAML_Mapping__mdt
            WHERE DeveloperName = 'username'
            LIMIT 1
        ];
        
        // Step 2: Validate that exactly one record is found
        if (samlMappings.isEmpty()) {
            throw new CustomException('No CRS_SSO_SAML_Mapping__mdt record found with DeveloperName = "username".');
        }
        System.debug('Found CRS_SSO_SAML_Mapping__mdt record with DeveloperName: ' + samlMappings[0].DeveloperName);
        
        // Step 3: Prepare the Metadata API update
        try {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
        
            // Construct the Custom Metadata record to update
            MetadataService.CustomMetadata customMetadata = new MetadataService.CustomMetadata();
            customMetadata.fullName = 'CRS_SSO_SAML_Mapping__mdt.' + samlMappings[0].DeveloperName;
            customMetadata.label = samlMappings[0].DeveloperName;
        
            // Define the fields to update
            MetadataService.CustomMetadataValue sandboxNameValue = new MetadataService.CustomMetadataValue();
            sandboxNameValue.field = 'CRS_SandBox_Name__c';
            sandboxNameValue.value = sandboxName;
            System.debug('Setting CRS_SandBox_Name__c to: ' + sandboxName);
        
            MetadataService.CustomMetadataValue isSandboxValue = new MetadataService.CustomMetadataValue();
            isSandboxValue.field = 'CRS_Is_SandBox__c';
            isSandboxValue.value = 'TRUE';
            System.debug('Setting CRS_Is_SandBox__c to: TRUE');
        
            MetadataService.CustomMetadataValue samlValValue = new MetadataService.CustomMetadataValue();
            samlValValue.field = 'CRS_Saml_Val__c';
            samlValValue.value = 'email';
            System.debug('Setting CRS_Saml_Val__c to: email');
        
            MetadataService.CustomMetadataValue sfValValue = new MetadataService.CustomMetadataValue();
            sfValValue.field = 'CRS_SF_Val__c';
            sfValValue.value = 'username';
            System.debug('Setting CRS_SF_Val__c to: username');
        
            customMetadata.values = new MetadataService.CustomMetadataValue[] {
                sandboxNameValue, isSandboxValue, samlValValue, sfValValue
            };
        
            // Step 4: Perform the Metadata API update
            System.debug('Initiating Metadata API update for CRS_SSO_SAML_Mapping__mdt record');
            MetadataService.Metadata[] metadata = new MetadataService.Metadata[] { customMetadata };
            MetadataService.UpsertResult[] results = service.upsertMetadata(metadata);
        
            // Step 5: Check the result of the Metadata API operation
            for (MetadataService.UpsertResult result : results) {
                if (!result.success) {
                    String errorMessage = 'Failed to update CRS_SSO_SAML_Mapping__mdt: ';
                    for (MetadataService.Error error : result.errors) {
                        errorMessage += error.message + '; ';
                    }
                    throw new CustomException(errorMessage);
                } else {
                    System.debug('Successfully updated CRS_SSO_SAML_Mapping__mdt record with Sandbox_Name__c: ' + sandboxName);
                }
            }
        } catch (Exception e) {
            System.debug('Error updating CRS_SSO_SAML_Mapping__mdt: ' + e.getMessage());
            throw new CustomException('Failed to update CRS_SSO_SAML_Mapping__mdt: ' + e.getMessage());
        }
    }

    /**
     * @description Custom exception class for handling errors during the update process.
     */
    public class CustomException extends Exception {}
}
