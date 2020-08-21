/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * This file demonstrates how to call the Salesforce Metadata API from Apex
 *   for warnings, limits and further todos of this approach please review the readme
 *   at https://github.com/financialforcedev/apex-mdapi for more information
 **/

public with sharing class MetadataServiceExamples
{
    public static void createObject()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'Test__c';
        customObject.label = 'Test';
        customObject.pluralLabel = 'Tests';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customObject });
        handleSaveResults(results[0]);
    }

    public static void upsertObject()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'Test__c';
        customObject.label = 'Test';
        customObject.pluralLabel = 'Tests Upsert';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record Upsert';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        List<MetadataService.UpsertResult> results =
            service.upsertMetadata(
                new MetadataService.Metadata[] { customObject });
        handleUpsertResults(results[0]);
    }

    public static void createLookupField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.LookupField__c';
        customField.label = 'Lookup Field';
        customField.type_x = 'Lookup';
        customField.relationshipLabel = 'Tests';
        customField.relationshipName = 'Tests';
        customField.referenceTo = 'Test__c';
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    public static void createExternalField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.ExternalField__c';
        customField.label = 'External Field';
        customField.type_x = 'Text';
        customField.length = 42;
        customField.externalId = true;
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    public static void createLongTextAreaField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.LongTextAreaField__c';
        customField.label = 'Long Text Area Field';
        customField.type_x = 'LongTextArea';
        customField.length = 32000;
        customField.visibleLines = 3;
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    public static void createField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.TestField__c';
        customField.label = 'Test Field';
        customField.type_x = 'Text';
        customField.length = 42;
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    public static void deleteField()
    {
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results =
            service.deleteMetadata(
                'CustomField', new String[] { 'Test__c.TestField__c' });
        handleDeleteResults(results[0]);
    }

    public static void updateField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.TestField__c';
        customField.label='New Test Field Label';
        customField.type_x = 'Text';
        customField.length = 52;
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    /**
     * NOTE: Consider using Permission Sets, these can also be created and assignd with DML in Apex
     **/
    public static void updateFieldLevelSecurity()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.Profile admin = new MetadataService.Profile();
        admin.fullName = 'Admin';
        admin.custom = false;
        MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec.field='Test__c.TestField__c';
        fieldSec.editable=true;
        admin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec} ;
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { admin });
        handleSaveResults(results[0]);
    }

    public static void updateTabVisibility()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.Profile admin = (MetadataService.Profile) service.readMetadata('Profile', new String[] { 'Admin' }).getRecords()[0];
        MetadataService.ProfileTabVisibility tabVis = new MetadataService.ProfileTabVisibility();
        tabVis.tab = 'Test_Tab__c';
        tabVis.visibility = 'Hidden';
        admin.tabVisibilities = new MetadataService.ProfileTabVisibility[] {tabVis};
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { admin });
        handleSaveResults(results[0]);
    }

    public static void updateCustomApplication()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomApplication customApp = (MetadataService.CustomApplication) service.readMetadata('CustomApplication', new String[] { 'Test_Application' }).getRecords()[0];
        customApp.defaultLandingTab = 'Test_Tab__c';
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { customApp });

        handleSaveResults(results[0]);
    }

    public static void createPage()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
        apexPage.apiVersion = 25;
        apexPage.fullName = 'test';
        apexPage.label = 'Test Page';
        apexPage.content = EncodingUtil.base64Encode(Blob.valueOf('<apex:page/>'));
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { apexPage });
        handleSaveResults(results[0]);
    }

    public static void createStaticResource()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
        staticResource.fullName = 'test';
        staticResource.contentType = 'text';
        staticResource.cacheControl = 'public';
        staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff'));
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { staticResource });
        handleSaveResults(results[0]);
    }

    public static void updateStaticResource()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
        staticResource.fullName = 'test';
        staticResource.contentType = 'text';
        staticResource.cacheControl = 'public';
        staticResource.content = EncodingUtil.base64Encode(Blob.valueOf('Static stuff Changed'));
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { staticResource });
        handleSaveResults(results[0]);
    }

    public static void deleteStaticResource()
    {
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results =
            service.deleteMetadata(
                'StaticResource', new String[] { 'test' });
        handleDeleteResults(results[0]);
    }

    public static void createWebLink()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.WebLink webLink = new MetadataService.WebLink();
        webLink.fullName = 'Test__c.googleButton';
        webLink.availability = 'online';
        webLink.displayType = 'link';
        webLink.encodingKey = 'UTF-8';
        webLink.hasMenubar = false;
        webLink.hasScrollbars = true;
        webLink.hasToolbar = false;
        webLink.height = 600;
        webLink.isResizable = true;
        webLink.linkType = 'url';
        webLink.masterLabel = 'google';
        webLink.openType = 'newWindow';
        webLink.position = 'none';
        webLink.protected_x = false;
        webLink.showsLocation = false;
        webLink.showsStatus = false;
        webLink.url = 'http://www.google.com';
        webLink.width = 600;
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { webLink });
        handleSaveResults(results[0]);
    }

    public static void listMetadata()
    {
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryWorkflow = new MetadataService.ListMetadataQuery();
        queryWorkflow.type_x = 'Workflow';
        queries.add(queryWorkflow);
        MetadataService.ListMetadataQuery queryValidationRule = new MetadataService.ListMetadataQuery();
        queryValidationRule.type_x = 'ValidationRule';
        queries.add(queryValidationRule);
        MetadataService.ListMetadataQuery queryCustomField = new MetadataService.ListMetadataQuery();
        queryCustomField.type_x = 'CustomField';
        queries.add(queryCustomField);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        for(MetadataService.FileProperties fileProperty : fileProperties)
            System.debug(fileProperty.fullName);
    }

	/*
	* Piclkist in CustomField has been deprecated use valueSet instead
    public static void createPicklistField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Lead.picklist__c';
        customField.label = 'picklist';
        customField.type_x = 'Picklist';
        metadataservice.Picklist pt = new metadataservice.Picklist();
        pt.sorted= false;
        metadataservice.PicklistValue one = new metadataservice.PicklistValue();
        one.fullName= 'first';
        one.default_x=false ;
        pt.picklistValues = new List<MetadataService.PicklistValue>{one};
        customField.picklist = pt ;
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    public static void updatePicklistField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Lead.picklist__c';
        customField.label = 'picklist';
        customField.type_x = 'Picklist';
        metadataservice.Picklist pt = new metadataservice.Picklist();
        pt.sorted= false;
        metadataservice.PicklistValue two = new metadataservice.PicklistValue();
        two.fullName= 'second';
        two.default_x=false ;
        metadataservice.PicklistValue three = new metadataservice.PicklistValue();
        three.fullName= 'third';
        three.default_x=false ;
        pt.picklistValues = new list<metadataservice.PicklistValue>{two,three};
        customField.picklist = pt ;
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }*/

    /**
     * Example of how to retrieve dependent picklist values
     * when you are NOT using record types on the object.
     * If using record types, please see other example getDependentPicklistValuesByRecordType().
     *
     * Setup:
     *   1. In a dev org, create a field dependency on the Account object with Active__c picklist controlling values in CustomerPriority__c picklist
     *      1a. When Active__c = Yes then let CustomerPriority__c include High
     *      1b. When Active__c = No then let CustomerPriority__c include Low
     *   2. Verify intended behavior by creating a new account record via browser. When Active__c = Yes then CustomerPriority__c should allow you to choose High.
     *   3. Run the below example snippet to see that the same filtered picklist values come back
     *
     * https://github.com/financialforcedev/apex-mdapi/issues/93
     * https://help.salesforce.com/HTViewHelpDoc?id=fields_defining_field_dependencies.htm
     
    public static void getDependentPicklistValues()
    {
        // Create service
        MetadataService.MetadataPort service = createService();

        // Read Custom Field (dependent picklist)
        MetadataService.CustomField customField = (MetadataService.CustomField) service.readMetadata(
            'CustomField', new String[] { 'Account.CustomerPriority__c' }
        ).getRecords()[0];

        // At the end of this example, this list will contain only those picklist values
        // that satisfy the picklist dependency of the controlling field's value.
        // The controlling field is the 'Active__c' picklist field.
        List<MetadataService.PicklistValue> filteredDependentValues = new List<MetadataService.PicklistValue>();

        for ( MetadataService.PicklistValue picklistValue : customField.picklist.picklistValues ) {
            // In this example the controlling field, Account.Active__c, has selected value of 'Yes'
            // so if the PicklistValue entry we're iterating over right now is controlled by that value
            // then we'll add it to our filtered list, otherwise we must ignore it.
            // The controlling field value could come from other user input, hard code, etc...
            String controllingFieldValue = 'Yes';
            if ( ( picklistValue.controllingFieldValues == null ) || new Set<String>( picklistValue.controllingFieldValues ).contains( controllingFieldValue ) ) {
                filteredDependentValues.add( picklistValue );
            }
        }

        System.debug( 'Filtered, Dependent Values = ' + filteredDependentValues );

    }*/

    /**
     * Example of how to retrieve the dependent picklist values that are both:
     *      1. Assigned to the record type, and
     *      2. Have a dependency upon the specified value from the controlling field
     *
     * Setup:
     *   1. In a dev org, create a field dependency on the Account object with Active__c picklist controlling values in CustomerPriority__c picklist
     *      1a. When Active__c = Yes then let CustomerPriority__c include High
     *      1b. When Active__c = No then let CustomerPriority__c include Low
     *   2. Create an Account record type called Record_Type_A and allow all values for Active__c be available but only allow CustomerPriority__c to have High and Low (exclude Medium)
     *   3. Verify intended behavior by creating a new account record via browser. When Active__c = Yes then CustomerPriority__c should allow you to choose High.
     *   4. Run the below example snippet to see that the same filtered picklist values come back
     *
     * https://github.com/financialforcedev/apex-mdapi/issues/93
     * https://help.salesforce.com/HTViewHelpDoc?id=fields_defining_field_dependencies.htm
     
    public static void getDependentPicklistValuesByRecordType()
    {
        // Create service
        MetadataService.MetadataPort service = createService();

        // Read Custom Field (dependent picklist)
        MetadataService.CustomField customField = (MetadataService.CustomField) service.readMetadata(
            'CustomField', new String[] { 'Account.CustomerPriority__c' }
        ).getRecords()[0];

        // Print each picklist value
        // At this point we will see every value assigned to this field
        // regardless of record type or controlling field value
        for ( MetadataService.PicklistValue pk : customField.picklist.picklistValues ) {
            System.debug( pk );
        }

        // Read Record Type
        MetadataService.RecordType recordType = (MetadataService.RecordType) service.readMetadata(
            'RecordType', new String[] { 'Account.Record_Type_A' }
        ).getRecords()[0];

        System.debug( recordType );

        // Build map of all picklist values by name configured for the field.
        // This is necessary because only these references have the 'controllingFieldValues' property defined.
        // When picklist values are retrieved via RecordType then this property is null, unfortunately.
        Map<String, MetadataService.PicklistValue> picklistValuesMap = new Map<String, MetadataService.PicklistValue>();
        for ( MetadataService.PicklistValue pk : customField.picklist.picklistValues ) {
            picklistValuesMap.put( pk.fullName, pk );
        }

        System.debug( picklistValuesMap );

        // At the end of this example, this list will contain only those picklist values
        // that are both assigned to the RecordType and satisfy the
        // picklist dependency of the controlling field's value.
        // The controlling field is the 'Active__c' picklist field.
        List<MetadataService.PicklistValue> filteredDependentValues = new List<MetadataService.PicklistValue>();

        // Of all the picklist values setup for the Account.CustomerPriority__c field,
        // iterate over the values explicitly assigned to the Account.Record_Type_A record type.
        for ( MetadataService.RecordTypePicklistValue rpk : recordType.picklistValues ) {
            if ( 'CustomerPriority__c' == rpk.picklist ) {
                for ( MetadataService.PicklistValue pk : rpk.values ) {

                    // Since the Metadata API does not provide the 'controllingFieldValues' property
                    // on the PicklistValues of the RecordType metadata response, we must now look that data up
                    // from the map we built earlier of the PicklistValues of the CustomField metadata response
                    MetadataService.PicklistValue picklistValue = picklistValuesMap.get( pk.fullName );

                    // In this example the controlling field, Account.Active__c, has selected value of 'Yes'
                    // so if the PicklistValue entry we're iterating over right now is controlled by that value
                    // then we'll add it to our filtered list, otherwise we must ignore it.
                    // The controlling field value could come from other user input, hard code, etc...
                    String controllingFieldValue = 'Yes';
                    if ( ( picklistValue.controllingFieldValues == null ) || new Set<String>( picklistValue.controllingFieldValues ).contains( controllingFieldValue ) ) {
                        filteredDependentValues.add( picklistValue );
                    }

                }
            }
        }

        System.debug( 'Filtered, Dependent Values = ' + filteredDependentValues );

    }*/

    public static void createAddressSettings()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.AddressSettings addressSettings = new MetadataService.AddressSettings();
        addressSettings.fullName = 'Address';
        addressSettings.countriesAndStates = new MetadataService.CountriesAndStates();
        MetadataService.Country us = new MetadataService.Country();
        us.active = true;
        us.integrationValue = 'United States';
        us.isoCode = 'US';
        us.label = 'United States';
        MetadataService.State stateAL = new MetadataService.State();
        stateAL.active = true;
        stateAL.integrationValue = 'Alabama';
        stateAL.isoCode = 'AL';
        stateAL.label = 'Alabama';
        MetadataService.State stateAK = new MetadataService.State();
        stateAK.active = true;
        stateAK.integrationValue = 'Alaska';
        stateAK.isoCode = 'AK';
        stateAK.label = 'Alaska';
        us.states = new List<MetadataService.State> { stateAL, stateAK };
        addressSettings.countriesAndStates.countries = new List<MetadataService.Country> { us };
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { addressSettings });
        handleSaveResults(results[0]);
    }

    public static void updateCaseSettings()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CaseSettings caseSettings = new MetadataService.CaseSettings();
        caseSettings.fullName = 'Case';
        caseSettings.notifyOwnerOnCaseComment = true;
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { caseSettings });
        handleSaveResults(results[0]);
    }

    public static void dynamicCreation(String objectName)
    {
        // Define Metadata item to create a Custom Object
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = objectName + '__c';
        customObject.label = objectName;
        customObject.pluralLabel = objectName+'s';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';

        // Define Metadata item to create a Custom Field on the above object
        MetadataService.CustomField customField1 = new MetadataService.CustomField();
        customField1.fullName = objectName+'__c.TestField1__c';
        customField1.label = 'Test Field 1';
        customField1.type_x = 'Text';
        customField1.length = 42;

        // Define Metadata item to create a Custom Field on the above object
        MetadataService.CustomField customField2 = new MetadataService.CustomField();
        customField2.fullName = objectName+'__c.TestField2__c';
        customField2.label = 'Test Field 2';
        customField2.type_x = 'Text';
        customField2.length = 42;

        // Define Metadata item to create a Visualforce page to display the above field
        MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
        apexPage.apiVersion = 25;
        apexPage.fullName = objectName.toLowercase();
        apexPage.label = objectName + ' Page';
        apexPage.content = EncodingUtil.base64Encode(Blob.valueOf(
            '<apex:page standardController=\''+objectName+'__c\'>'+
                '{!' + objectName + '__c.TestField1__c}' +
                '{!' + objectName + '__c.TestField2__c}' +
            '</apex:page>'));

        // Create components in the correct order
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customObject });
        handleSaveResults(results[0]);
        results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField1, customField2 });
        handleSaveResults(results[0]);
        handleSaveResults(results[1]);
        results =
            service.createMetadata(
                new MetadataService.Metadata[] { apexPage });
        handleSaveResults(results[0]);
    }

    public static void createRecordType()
    {
        MetadataService.RecordType recordType = new MetadataService.RecordType();
        recordType.active = true;
        recordType.fullName = 'Test__c.RecordTypeA';
        recordType.label = 'Record Type A';
        recordType.businessProcess = null;
        recordType.description = 'My new record type';

        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { recordType });
        handleSaveResults(results[0]);
    }

    public static void deleteRecordType()
    {
        // Salesforce bug? The follow results in 'Cannot delete record type through API'
        //   yet the docs say otherwise, http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_recordtype.htm
        //   'For more information, see “Record Types Overview” in the Salesforce online help.
        //    Use this metadata type to create, update, or delete record type definitions for a custom object.'
        MetadataService.RecordType recordType = new MetadataService.RecordType();
        recordType.active = true;
        recordType.fullName = 'Test__c.RecordTypeA';
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results =
            service.deleteMetadata(
                'RecordType', new String[] { 'Test__c.RecordTypeA' });
        handleDeleteResults(results[0]);
    }

    public static void installPackages()
    {
        // Install packageA, then pacakgeB
        MetadataService.InstalledPackage installedPackageA = new MetadataService.InstalledPackage();
        installedPackageA.password = 'fred1234';
        installedPackageA.versionNumber = '1.0';
        installedPackageA.fullName = 'packagea';
        MetadataService.InstalledPackage installedPackageB = new MetadataService.InstalledPackage();
        installedPackageB.versionNumber = '1.0';
        installedPackageB.fullName = 'packageb';

        // Install the packages
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { installedPackageA, installedPackageB });
        handleSaveResults(results[0]);
        handleSaveResults(results[1]);
    }

    public static void uninstallPackages()
    {
        // Uninstall packages
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results =
            service.deleteMetadata(
                'InstalledPackage', new String[] { 'packagea', 'packageb' });
        handleDeleteResults(results[0]);
        handleDeleteResults(results[1]);
    }

    public static void createCustomSite()
    {
        MetadataService.CustomSite customSite = new MetadataService.CustomSite();
        customSite.fullName = 'MyCustomSite';
        customSite.active = true;
        customSite.allowHomePage = true;
        customSite.allowStandardIdeasPages = true;
        customSite.active = true;
        customSite.allowHomePage = true;
        customSite.allowStandardIdeasPages = true;
        customSite.allowStandardLookups = true;
        customSite.allowStandardSearch = true;
        customSite.authorizationRequiredPage = 'Unauthorized';
        customSite.bandwidthExceededPage = 'BandwidthExceeded';
        customSite.changePasswordPage = 'ChangePassword';
        customSite.chatterAnswersForgotPasswordConfirmPage = null;
        customSite.chatterAnswersForgotPasswordPage = null;
        customSite.chatterAnswersHelpPage = null;
        customSite.chatterAnswersLoginPage = null;
        customSite.chatterAnswersRegistrationPage = null;
        customSite.favoriteIcon = null;
        customSite.fileNotFoundPage = 'FileNotFound';
        customSite.genericErrorPage = 'Exception';
        customSite.inMaintenancePage = 'InMaintenance';
        customSite.serverIsDown =  null;
        customSite.indexPage = 'UnderConstruction';
        customSite.masterLabel = 'customSite';
        customSite.portal = null;
        customSite.requireInsecurePortalAccess = false;
        customSite.siteAdmin = 'admin@mysiteorg.com';
        customSite.siteTemplate = 'SiteTemplate';
        customSite.siteType = 'Visualforce';
        customSite.clickjackProtectionLevel = 'AllowAllFraming';
        customSite.requireHttps = true;
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customSite });
        handleSaveResults(results[0]);
    }

    public static void createDetailObject()
    {
        // Define Metadata item to create a Custom Object
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'TestDetail__c';
        customObject.label = 'Test Detail';
        customObject.pluralLabel = 'Test Details';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Detail Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';

        // Define Metadata item to create a Custom Formula Field on the above object
        MetadataService.CustomField customField1 = new MetadataService.CustomField();
        customField1.fullName = 'TestDetail__c.FormulaField__c';
        customField1.externalId = false;
        customField1.formula = '42';
        customField1.formulaTreatBlanksAs = 'BlankAsZero';
        customField1.label = 'Formula Field';
        customField1.precision = 18;
        customField1.required = false;
        customField1.scale = 2;
        customField1.type_x = 'Number';
        customField1.unique = false;

        // Define Metadata item to create a Custom Field on the above object
        MetadataService.CustomField customField2 = new MetadataService.CustomField();
        customField2.fullName = 'TestDetail__c.Test__c';
        customField2.externalId = false;
        customField2.label = 'Test';
        customField2.referenceTo = 'Test__c';
        customField2.relationshipLabel = 'Test Children';
        customField2.relationshipName = 'Test_Children';
        customField2.relationshipOrder = 0;
        customField2.type_x = 'MasterDetail';
        customField2.writeRequiresMasterRead = false;

        // Create components in the correct order
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customObject });
        handleSaveResults(results[0]);
        results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField1, customField2 });
        handleSaveResults(results[0]);
        handleSaveResults(results[1]);
    }

    public static void createFieldSet()
    {
        MetadataService.MetadataPort service = createService();

        // FieldSet
        MetadataService.FieldSet fieldSet = new MetadataService.FieldSet();
        fieldSet.fullName = 'Test__c.MyFieldSet';
        fieldSet.label = 'My FieldSet';
        fieldSet.description = 'Used by my VF page';
        MetadataService.FieldSetItem myAvailableField = new MetadataService.FieldSetItem();
        myAvailableField.field = 'TestField__c';
        myAvailableField.isFieldManaged = true;
        myAvailableField.isRequired = true;
        fieldSet.availableFields = new List<MetadataService.FieldSetItem>();
        fieldSet.availableFields.add(myAvailableField);

        // Create
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { fieldSet });
        handleSaveResults(results[0]);
    }

    public static void updateFieldSet()
    {
        MetadataService.MetadataPort service = createService();

        // FieldSet
        MetadataService.FieldSet fieldSet = new MetadataService.FieldSet();
        fieldSet.fullName = 'Test__c.MyFieldSet';
        fieldSet.label = 'My FieldSet';
        fieldSet.description = 'Used by my VF page';
        MetadataService.FieldSetItem myAvailableField = new MetadataService.FieldSetItem();
        myAvailableField.field = 'TestField__c';
        myAvailableField.isFieldManaged = true;
        myAvailableField.isRequired = true;
        MetadataService.FieldSetItem myAvailableFieldNew = new MetadataService.FieldSetItem();
        myAvailableFieldNew.field = 'ExternalField__c';
        myAvailableFieldNew.isFieldManaged = true;
        myAvailableFieldNew.isRequired = true;
        fieldSet.availableFields = new List<MetadataService.FieldSetItem>();
        fieldSet.availableFields.add(myAvailableField);
        fieldSet.availableFields.add(myAvailableFieldNew);

        // Update
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { fieldSet });
        handleSaveResults(results[0]);
    }

    public static void addActionOverride()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'Test__c';
        customObject.label = 'Test';
        customObject.pluralLabel = 'Tests';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        customObject.actionOverrides = new List<MetadataService.ActionOverride>();
        customObject.actionOverrides.add(new MetadataService.ActionOverride());
        customObject.actionOverrides[0].actionName = 'Edit';
        customObject.actionOverrides[0].content = 'TestPage';
        customObject.actionOverrides[0].type_x = 'visualforce';
        customObject.actionOverrides[0].skipRecordTypeSelect = false;
        customObject.actionOverrides[0].comment = 'A comment for edit action';
        List<MetadataService.SaveResult> results =
            service.updateMetadata(
                new MetadataService.Metadata[] { customObject });
        handleSaveResults(results[0]);
    }

    public static void createListView()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.ListView listView = new MetadataService.ListView();
        listView.fullName = 'Test__c.MyListView';
        listView.label = 'My List View';
        listView.filterScope = 'Everything';
        listView.columns = new List<String> { 'NAME' };
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { listView });
        handleSaveResults(results[0]);
    }

    public static void deleteListView()
    {
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results =
            service.deleteMetadata(
                'ListView', new String[] { 'Test__c.MyListView' });
        handleDeleteResults(results[0]);
    }

    public static void listListViews()
    {
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
        listView.type_x = 'ListView';
        queries.add(listView);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        for(MetadataService.FileProperties fileProperty : fileProperties)
            System.debug(fileProperty.fullName);
    }

    public static void readListView()
    {
        MetadataService.MetadataPort service = createService();

        // Read List View definition
        MetadataService.ListView listView =
            (MetadataService.ListView) service.readMetadata('ListView',
                new String[] { 'Test__c.MyListView' }).getRecords()[0];
        if(listView.columns!=null)
            for(String column : listView.columns)
                System.debug('Column ' + column);
        if(listView.filters!=null)
            for(MetadataService.ListViewFilter filter : listView.filters)
                System.debug('Filter ' + filter.field + ' ' + filter.operation + ' ' + filter.value);
    }

    public static void createApprovalProcess()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.ApprovalProcess approvalProcess = new MetadataService.ApprovalProcess();
        approvalProcess.fullName = 'Test__c.TestApproval';
        approvalProcess.label = 'Test Approval';
        approvalProcess.active = false;
        approvalProcess.allowRecall = false;
        approvalProcess.showApprovalHistory = true;
        approvalProcess.recordEditability = 'AdminOnly';
        approvalProcess.finalApprovalRecordLock = false;
        approvalProcess.finalRejectionRecordLock = false;
        approvalProcess.showApprovalHistory = false;
        MetadataService.ApprovalSubmitter submitter = new MetadataService.ApprovalSubmitter();
        submitter.type_x = 'user';
        submitter.submitter = UserInfo.getUserName();
        approvalProcess.allowedSubmitters = new List<MetadataService.ApprovalSubmitter> { submitter };
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { approvalProcess });
        handleSaveResults(results[0]);
    }

    public static void readAndUpdateLayout()
    {
        MetadataService.MetadataPort service = createService();

        // Create Button
        MetadataService.WebLink webLink = new MetadataService.WebLink();
        webLink.fullName = 'Test__c.googleButton';
        webLink.availability = 'online';
        webLink.displayType = 'button';
        webLink.encodingKey = 'UTF-8';
        webLink.hasMenubar = false;
        webLink.hasScrollbars = true;
        webLink.hasToolbar = false;
        webLink.height = 600;
        webLink.isResizable = true;
        webLink.linkType = 'url';
        webLink.masterLabel = 'google';
        webLink.openType = 'newWindow';
        webLink.position = 'none';
        webLink.protected_x = false;
        webLink.showsLocation = false;
        webLink.showsStatus = false;
        webLink.url = 'http://www.google.com';
        webLink.width = 600;
        handleSaveResults(
            service.createMetadata(
                new List<MetadataService.Metadata> { webLink })[0]);

        // Read the Layout
        MetadataService.Layout layout =
            (MetadataService.Layout) service.readMetadata('Layout',
                new String[] { 'Test__c-Test Layout' }).getRecords()[0];

        // Add the Custom Button to the Layout
        if(layout.customButtons==null)
            layout.customButtons = new List<String>();
        layout.customButtons.add('googleButton');

        // Update the Layout
        handleSaveResults(
            service.updateMetadata(
                new MetadataService.Metadata[] { layout })[0]);
    }


    public static void addFieldToLayout()
    {
        MetadataService.MetadataPort service = createService();

        // Read the Layout
        MetadataService.Layout layout =
            (MetadataService.Layout) service.readMetadata('Layout',
                new String[] { 'Test__c-Test Layout' }).getRecords()[0];

        // Add Layout section, layout, item and field
        if(layout.layoutSections==null)
            layout.layoutSections = new List<MetadataService.LayoutSection>();
        MetadataService.LayoutSection newLayoutSection = new MetadataService.LayoutSection();
        newLayoutSection.style = 'OneColumn';
        MetadataService.LayoutColumn newLayoutColumn = new MetadataService.LayoutColumn();
        MetadataService.LayoutItem newLayoutItem = new MetadataService.LayoutItem();
        newLayoutItem.field = 'TestField__c';
        newLayoutColumn.layoutItems = new List<MetadataService.LayoutItem> { newLayoutItem };
        newLayoutSection.layoutColumns = new List<MetadataService.LayoutColumn> { newLayoutColumn };
        layout.layoutSections.add(newLayoutSection);

        // Update the Layout
        handleSaveResults(
            service.updateMetadata(
                new MetadataService.Metadata[] { layout })[0]);
    }

    /*public static void updatePicklist()
    {
        MetadataService.MetadataPort service = createService();

        // Read Custom Field
        MetadataService.CustomField customField =
            (MetadataService.CustomField) service.readMetadata('CustomField',
                new String[] { 'Lead.picklist__c' }).getRecords()[0];

        // Add pick list values
        metadataservice.PicklistValue two = new metadataservice.PicklistValue();
        two.fullName= 'second';
        two.default_x=false;
        metadataservice.PicklistValue three = new metadataservice.PicklistValue();
        three.fullName= 'third';
        three.default_x=false;
        customField.picklist.picklistValues.add(two);
        customField.picklist.picklistValues.add(three);

        // Update Custom Field
        handleSaveResults(
            service.updateMetadata(
                new MetadataService.Metadata[] { customField })[0]);
    }*/

    public static void copyLayoutSection()
    {
        MetadataService.MetadataPort service = createService();

        // Read the source Layout
        MetadataService.Layout sourceLayout =
            (MetadataService.Layout) service.readMetadata('Layout',
                new String[] { 'Test__c-Test Template Layout' }).getRecords()[0];

        // Read the target Layout
        MetadataService.Layout targetLayout =
            (MetadataService.Layout) service.readMetadata('Layout',
                new String[] { 'Test__c-Test Layout' }).getRecords()[0];

        // Add section from source Layout to target Layout
        targetLayout.layoutSections.add(
            sourceLayout.layoutSections[0]);

        // Update target Layout
        handleSaveResults(
            service.updateMetadata(
                new MetadataService.Metadata[] { targetLayout })[0]);
    }

    public static void readWorkflowAlert()
    {
        MetadataService.MetadataPort service = createService();

        // Read Workflow Alert
        MetadataService.WorkflowAlert wfa =
            (MetadataService.WorkflowAlert) service.readMetadata('WorkflowAlert',
                new String[] { 'Test__c.Test' }).getRecords()[0];
        System.debug('Description ' + wfa.description);
        System.debug('Sender Address ' + wfa.senderAddress);
    }

    public static void readCustomObject()
    {
        MetadataService.MetadataPort service = createService();

        MetadataService.CustomObject customObject =
            (MetadataService.CustomObject) service.readMetadata('CustomObject',
                new String[] { 'Test__c' }).getRecords()[0];
        for(MetadataService.CustomField field : customObject.fields)
            System.debug(field.fullName);
    }

    public static void addComponentsToHomePageLayout()
    {
        // Retrieve Home Page Layout
        MetadataService.MetadataPort service = createService();
        MetadataService.HomePageLayout homePageLayout =
            (MetadataService.HomePageLayout) service.readMetadata('HomePageLayout',
                new String[] { 'DE Default' }).getRecords()[0];

        // Create Home Page Component
        MetadataService.HomePageComponent homePageComponent =
            new MetadataService.HomePageComponent();
        homePageComponent.width = 'wide';
        homePageComponent.pageComponentType = 'htmlArea';
        homePageComponent.fullName = 'helloworld';
        homePageComponent.body = '<p>Hello World</p>';
        handleSaveResults(
            service.createMetadata(
                new MetadataService.Metadata[] { homePageComponent })[0]);

        // Add component to Home Page Layout and Update
        if(homePageLayout.wideComponents==null)
            homePageLayout.wideComponents = new List<String>();
        homePageLayout.wideComponents.add('helloworld');
        handleSaveResults(
            service.updateMetadata(
                new MetadataService.Metadata[] { homePageLayout })[0]);
    }

    public static void readFolder()
    {
        // Retrieve Folder
        MetadataService.MetadataPort service = createService();
        MetadataService.ReportFolder folder =
            (MetadataService.ReportFolder) service.readMetadata('ReportFolder',
                new String[] { 'MyFolder' }).getRecords()[0];
        System.debug('name ' + folder.name);
        System.debug('fullName ' + folder.fullName);
        System.debug('allInternalUsers ' + folder.sharedTo.allInternalUsers);
    }

    public static void readReport()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.Report report =
            (MetadataService.Report) service.readMetadata('Report',
                new String[] { 'MyFolder/MyReport' }).getRecords()[0];
        System.debug(report.description);
    }

    public static void readPermissionSet()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.PermissionSet ps =
            (MetadataService.PermissionSet) service.readMetadata('PermissionSet',
                new String[] { 'Test' }).getRecords()[0];

    }

    public static void createLayout()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.Layout layout = new MetadataService.Layout();
        layout.fullName = 'Test__c-My Layout';
        layout.layoutSections = new List<MetadataService.LayoutSection>();
        MetadataService.LayoutSection layoutSection = new MetadataService.LayoutSection();
        layoutSection.editHeading = true;
        layoutSection.label = 'System Information';
        layoutSection.style = 'TwoColumnsTopToBottom';
        layoutSection.layoutColumns = new List<MetadataService.LayoutColumn>();
        MetadataService.LayoutColumn layoutColumn = new MetadataService.LayoutColumn();
        layoutColumn.layoutItems = new List<MetadataService.LayoutItem>();
        MetadataService.LayoutItem layoutItem1 = new MetadataService.LayoutItem();
        layoutItem1.behavior = 'Readonly';
        layoutItem1.field = 'CreatedById';
        layoutColumn.layoutItems.add(layoutItem1);
        MetadataService.LayoutItem layoutItem2 = new MetadataService.LayoutItem();
        layoutItem2.behavior = 'Required';
        layoutItem2.field = 'Name';
        layoutColumn.layoutItems.add(layoutItem2);
        layoutSection.layoutColumns.add(layoutColumn);
        layout.layoutSections.add(layoutSection);
        layout.summaryLayout = new MetadataService.SummaryLayout();
        layout.summaryLayout.masterLabel = 'Great name';
        layout.summaryLayout.sizeX = 4;
        layout.summaryLayout.sizeY = 2;
        layout.summaryLayout.summaryLayoutStyle = 'Default';
        layout.summaryLayout.summaryLayoutItems = new List<MetadataService.SummaryLayoutItem>();
        MetadataService.SummaryLayoutItem summaryLayoutItem = new MetadataService.SummaryLayoutItem();
        summaryLayoutItem.posX = 0;
        summaryLayoutItem.posY = 0;
        summaryLayoutItem.field = 'Name';
        layout.summaryLayout.summaryLayoutItems.add(summaryLayoutItem);
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { layout });
        handleSaveResults(results[0]);
    }

    public static void readLightningComponent()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.AuraDefinitionBundle auraBundle =
            (MetadataService.AuraDefinitionBundle) service.readMetadata('AuraDefinitionBundle',
                new String[] { 'HelloWorld' }).getRecords()[0];
        System.debug(EncodingUtil.base64Decode(auraBundle.markup).toString());
    }

    public static void createLightningComponent()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.AuraDefinitionBundle auraBundle = new MetadataService.AuraDefinitionBundle();
        auraBundle.fullName = 'HelloWorld';
        auraBundle.type_x = 'Component';
        auraBundle.markup = EncodingUtil.base64Encode(Blob.valueOf(
            '<aura:component>' +
                '<aura:attribute name="val1" type="String" default="Value"/>' +
                '<aura:attribute name="val2" type="String" />' +
                '<aura:handler name="init" value="{!this}" action="{!c.myAction}"/>' +
                '<ui:outputText value="Hello world!"/>' +
                '<ui:outputText value="{!v.val1}"/>' +
                '<ui:outputText value="{!v.val2}"/>' +
            '</aura:component>'));
        auraBundle.controllerContent = EncodingUtil.base64Encode(Blob.valueOf(
            '({' +
                'myAction : function(component) {' +
                    'component.set(\'v.val1\',\'Value1\');' +
                    'component.set(\'v.val2\',\'Value2\');' +
                '}' +
            '})'));
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { auraBundle });
        handleSaveResults(results[0]);
    }

    public static void createFormulaField()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Test__c.TestFormulaField__c';
        customField.label = 'Test Formula Field';
        customField.type_x = 'Date';
        customField.formula = 'TODAY()';
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        handleSaveResults(results[0]);
    }

    public static void createLayoutManaged()
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.Layout layout = new MetadataService.Layout();
        layout.fullName = 'packageb__Sales_Invoice__c-Test';
        layout.layoutSections = new List<MetadataService.LayoutSection>();
        MetadataService.LayoutSection layoutSection = new MetadataService.LayoutSection();
        layoutSection.editHeading = true;
        layoutSection.label = 'System Information';
        layoutSection.style = 'TwoColumnsTopToBottom';
        layoutSection.layoutColumns = new List<MetadataService.LayoutColumn>();
        MetadataService.LayoutColumn layoutColumn = new MetadataService.LayoutColumn();
        layoutColumn.layoutItems = new List<MetadataService.LayoutItem>();
        MetadataService.LayoutItem layoutItem1 = new MetadataService.LayoutItem();
        layoutItem1.behavior = 'Readonly';
        layoutItem1.field = 'CreatedById';
        layoutColumn.layoutItems.add(layoutItem1);
        MetadataService.LayoutItem layoutItem2 = new MetadataService.LayoutItem();
        layoutItem2.behavior = 'Required';
        layoutItem2.field = 'Name';
        layoutColumn.layoutItems.add(layoutItem2);
        layoutSection.layoutColumns.add(layoutColumn);
        layout.layoutSections.add(layoutSection);
        List<MetadataService.UpsertResult> results =
            service.upsertMetadata(
                new MetadataService.Metadata[] { layout });
        handleUpsertResults(results[0]);
    }

    public static void createSharingRule()
    {
        // Create Sharing Rule
        MetadataService.MetadataPort service = createService();
        MetadataService.SharingRules testSharingRule = new MetadataService.SharingRules();
        testSharingRule.fullName = 'Test__c';
        testSharingRule.sharingCriteriaRules = new List<MetadataService.SharingCriteriaRule>();
        MetadataService.SharingCriteriaRule sharingCriteriaRule = new MetadataService.SharingCriteriaRule();
        sharingCriteriaRule.fullName = 'TestCriteria';
        sharingCriteriaRule.accessLevel = 'Read';
        sharingCriteriaRule.label = 'Test';
        sharingCriteriaRule.sharedTo = new MetadataService.SharedTo();
        sharingCriteriaRule.sharedTo.allPartnerUsers = '';
        sharingCriteriaRule.criteriaItems = new List<MetadataService.FilterItem>();
        MetadataService.FilterItem cirteriaFilterItem = new MetadataService.FilterItem();
        cirteriaFilterItem.field = 'RecordTypeId';
        cirteriaFilterItem.operation = 'equals';
        cirteriaFilterItem.value = 'Record Type A';
        sharingCriteriaRule.criteriaItems.add(cirteriaFilterItem);
        testSharingRule.sharingCriteriaRules.add(sharingCriteriaRule);
        testSharingRule.sharingOwnerRules = new List<MetadataService.SharingOwnerRule>();
        MetadataService.SharingOwnerRule sharingOwnerRule = new MetadataService.SharingOwnerRule();
        sharingOwnerRule.fullName = 'TestOwner';
        sharingOwnerRule.accessLevel = 'Read';
        sharingOwnerRule.label = 'Test';
        sharingOwnerRule.sharedTo = new MetadataService.SharedTo();
        sharingOwnerRule.sharedTo.allPartnerUsers = '';
        sharingOwnerRule.sharedFrom = new MetadataService.SharedTo();
        sharingOwnerRule.sharedFrom.allInternalUsers = '';
        testSharingRule.sharingOwnerRules.add(sharingOwnerRule);
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { testSharingRule });
        handleSaveResults(results[0]);
    }

    public static void readSharingRule()
    {
        // Read Sharing Rule
        MetadataService.MetadataPort service = createService();
        MetadataService.SharingRules sharingRules =
            (MetadataService.SharingRules) service.readMetadata('SharingRules',
                new String[] { 'Test__c' }).getRecords()[0];
        System.debug(sharingRules.sharingOwnerRules[0].fullName);
    }

    public static void deleteSharingRule()
    {
        // Delete Sharing Rule
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results =
            service.deleteMetadata(
                'SharingRules', new String[] { 'Test__c' });
        handleDeleteResults(results[0]);
    }

    public static void readTranslation()
    {
        // Read Translation
        MetadataService.MetadataPort service = createService();
        MetadataService.Translations translations =
            (MetadataService.Translations) service.readMetadata('Translations',
                new String[] { 'nl_NL' }).getRecords()[0];
        for(MetadataService.CustomLabelTranslation customLabelTranslation : translations.customLabels)
            System.debug(customLabelTranslation.label);
    }

    public static void readApprovalProcess()
    {
        // Read Translation
        MetadataService.MetadataPort service = createService();
        MetadataService.ApprovalProcess approvalProcess =
            (MetadataService.ApprovalProcess) service.readMetadata('ApprovalProcess',
                new String[] { 'Test__c.TestApproval' }).getRecords()[0];
    }

    public static void createCustomPageWeblink()
    {
        MetadataService.MetadataPort service = createService();

        MetadataService.CustomPageWebLink customPageWeblink = new MetadataService.CustomPageWebLink();

        //no object name here, no spaces, single "_" allowed
        customPageWeblink.fullName = 'CustomPageWeblink_Name';
        customPageWeblink.availability = 'online';
        customPageWeblink.displayType = 'link';
        customPageWeblink.encodingKey = 'UTF-8';
        customPageWeblink.hasMenubar = false;
        customPageWeblink.hasScrollbars = false;
        customPageWeblink.hasToolbar = false;
        customPageWeblink.height = 600;
        customPageWeblink.isResizable = false;
        customPageWeblink.linkType = 'url';
        //friendly name that is displayed on SFDc pages
        customPageWeblink.masterLabel = 'Label';
        customPageWeblink.openType = 'newWindow';
        customPageWeblink.position = 'none';
        customPageWeblink.protected_x = false;
        customPageWeblink.showsLocation = false;
        customPageWeblink.showsStatus = false;
        customPageWeblink.url = 'http://www.google.com';

        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customPageWeblink });

        handleSaveResults(results[0]);
    }

    /**
     * If you have subscribed to the paid feature add-on "Field Audit Trail" then you can define the
     * History Retention Policy using the Metadata API.
     *
     * https://developer.salesforce.com/docs/atlas.en-us.field_history_retention.meta/field_history_retention/
     * https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_historyretentionpolicy.htm
     */
    public static void updateHistoryRetentionPolicy() {

        // Create service
        MetadataService.MetadataPort service = createService();

        // Retrieve the custom object metadata
        MetadataService.CustomObject customObject = (MetadataService.CustomObject) service.readMetadata(
            'CustomObject', new String[] { 'Account' }
        ).getRecords()[0];

        // Print the existing policy, if any defined
        System.debug( customObject.historyRetentionPolicy );

        // Define the retention policy
        MetadataService.HistoryRetentionPolicy policy = new MetadataService.HistoryRetentionPolicy();
        policy.archiveAfterMonths = 3;
        policy.archiveRetentionYears = 5;
        policy.gracePeriodDays = 0;

        // Assign policy to the custom object
        customObject.historyRetentionPolicy = policy;

        // Update the metadata using API
        List<MetadataService.SaveResult> saveResults = service.updateMetadata(
            new MetadataService.Metadata[] {
                customObject
             }
        );

        // Inspect the save result for any errors
        for ( MetadataService.SaveResult saveResult : saveResults ) {
            if ( !saveResult.success ) {
                System.debug( 'failure' );
                for ( MetadataService.Error err : saveResult.errors ) {
                   System.debug( System.LoggingLevel.ERROR, err.statusCode + ': ' + err.message );
                }
            }
            System.debug( 'success' );
        }

    }

    public static void createFlow() {

        MetadataService.MetadataPort service = createService();

        // Create Flow
        MetadataService.Flow flow = new MetadataService.Flow();
        flow.fullName = 'NewFlow-1';
        flow.description = 'New Flow';
        flow.label = 'New Flow';
        flow.processType = 'Flow';
        MetadataService.FlowRecordCreate recordCreate = new MetadataService.FlowRecordCreate();
        recordCreate.name = 'RecordCreate';
        recordCreate.label = 'Record Create';
        recordCreate.object_x = 'Account';
        recordCreate.locationX = 10;
        recordCreate.locationY = 10;
        recordCreate.inputAssignments = new List<MetadataService.FlowInputFieldAssignment>();
        recordCreate.inputAssignments.add(new MetadataService.FlowInputFieldAssignment());
        recordCreate.inputAssignments[0].field = 'AccountNumber';
        recordCreate.inputAssignments[0].value = new MetadataService.FlowElementReferenceOrValue();
        recordCreate.inputAssignments[0].value.stringValue = '1234';
        flow.recordCreates = new List<MetadataService.FlowRecordCreate> { recordCreate };
        flow.startElementReference = 'RecordCreate';
        handleSaveResults(service.createMetadata(new List<MetadataService.Metadata> { flow })[0]);
    }

    public static void readFlow()
    {
        MetadataService.MetadataPort service = createService();

        // Read Flow
        MetadataService.Flow flow =
            (MetadataService.Flow) service.readMetadata('Flow',
                new String[] { 'NewFlow-1' }).getRecords()[0];
        System.debug('Description ' + flow.description);
        System.debug('Name ' + flow.RecordCreates[0].name);
        System.debug('Location X ' + flow.RecordCreates[0].locationX);
        System.debug('Location Y ' + flow.RecordCreates[0].locationY);
    }    

    public static void updateFlow() {
        
        MetadataService.MetadataPort service = createService();

        // Read Flow
        MetadataService.Flow flow =
            (MetadataService.Flow) service.readMetadata('Flow',
                new String[] { 'NewFlow-1' }).getRecords()[0];

        // Add a new step
        MetadataService.FlowScreen flowScreen = new MetadataService.FlowScreen();
        flowScreen.name = 'NewScreen';
        flowScreen.label = 'New Screen';
        flowScreen.locationX = 100;
        flowScreen.locationY = 100;
        flowScreen.allowBack = true;
        flowScreen.allowFinish = true;
        flowScreen.fields = new List<MetadataService.FlowScreenField>();
        flowScreen.fields.add(new MetadataService.FlowScreenField());
        flowScreen.fields[0].name = 'Test_Box';
        flowScreen.fields[0].dataType = 'String';
        flowScreen.fields[0].fieldText = 'Test Box';
        flowScreen.fields[0].fieldType = 'InputField';
        flowScreen.fields[0].isRequired = true;
        flow.screens = new List<MetadataService.FlowScreen> { flowScreen };

        // Link it with the previous one
        flow.recordCreates[0].connector = new MetadataService.FlowConnector();
        flow.recordCreates[0].connector.targetReference = 'NewScreen';

        // Update
        handleSaveResults(service.updateMetadata(new List<MetadataService.Metadata> { flow })[0]);
    }

    public static void deleteFlow() {

        MetadataService.MetadataPort service = createService();

        // Delete Flow
        handleDeleteResults(
            service.deleteMetadata('Flow', new String[] { 'NewFlow-1' })[0]);
    }


    public static void createFlowAdvanced() {
        
        MetadataService.MetadataPort service = createService();

        // Create Flow
        MetadataService.Flow flow = new MetadataService.Flow();
        flow.fullName = 'NewFlow-1';
        flow.description = 'New Flow';
        flow.label = 'New Flow';
        flow.processType = 'Flow';
        flow.startElementReference = 'NewScreen';        

        // Add a new step
        MetadataService.FlowScreen flowScreen = new MetadataService.FlowScreen();
        flowScreen.name = 'NewScreen';
        flowScreen.label = 'New Screen';
        flowScreen.locationX = 100;
        flowScreen.locationY = 100;
        flowScreen.allowBack = true;
        flowScreen.allowFinish = true;       
        addFields(flowScreen, 
            new List<SObjectField> { 
                Account.AccountNumber, 
                Account.Description, 
                Account.Fax,
                Account.AnnualRevenue });
        flow.screens = new List<MetadataService.FlowScreen> { flowScreen };

        // Create
        handleSaveResults(service.createMetadata(new List<MetadataService.Metadata> { flow })[0]);
    }

    public static final Map<DisplayType, String> FLOWTYPEBYDISPLAYTYPE = 
            new Map<DisplayType, String>{ 
                DisplayType.anytype => 'String',
                DisplayType.base64 => 'String',
                DisplayType.Boolean => 'Boolean', 
                DisplayType.Combobox => 'String',
                DisplayType.Currency => 'Currency',
                DisplayType.Date => 'Date',
                DisplayType.DateTime => 'DateTime', 
                DisplayType.Double => 'Number',
                DisplayType.Email => 'String',
                DisplayType.EncryptedString => 'String',
                DisplayType.Id => 'String',
                DisplayType.Integer => 'Number',
                DisplayType.MultiPicklist => 'Multipicklist',
                DisplayType.Percent => 'Number', 
                DisplayType.Phone => 'String',
                DisplayType.Picklist => 'Picklist',
                DisplayType.Reference => 'Reference',
                DisplayType.String => 'String',
                DisplayType.TextArea => 'String',
                DisplayType.Time => 'String',
                DisplayType.URL => 'String'};

    /**
     * This is for demo purposes only, it requires more work and testing to refine
     **/
    public static void addFields(MetadataService.FlowScreen flowScreen, List<SObjectField> fieldsToAdd) {
        for(SObjectField field : fieldsToAdd) {
            // Construct a FlowScreenField based on the SObjectField metadata
            DescribeFieldResult fieldDescribe = field.getDescribe();
            // https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_visual_workflow.htm#FlowScreenField
            MetadataService.FlowScreenField flowScreenField = new MetadataService.FlowScreenField();
            flowScreenField.name = fieldDescribe.getName();
            flowScreenField.dataType = FLOWTYPEBYDISPLAYTYPE.get(fieldDescribe.getType());
            flowScreenField.fieldText = fieldDescribe.getLabel();
            flowScreenField.fieldType = 'InputField';
            flowScreenField.isRequired = flowScreenField.dataType == 'Boolean' ? true : fieldDescribe.isNillable();            
            flowScreenField.helpText = fieldDescribe.getInlineHelpText();
            if(flowScreenField.dataType == 'Number') {
                flowScreenField.scale = fieldDescribe.getScale();
            }
            // Add to Screen field list
            if(flowScreen.fields==null)
                flowScreen.fields = new List<MetadataService.FlowScreenField>();
            flowScreen.fields.add(flowScreenField);
        }
    }

    public static void retrieveConnectedApp() {
        // This only seems to work for Connected App's created in the org, not those packaged, see Workbench only created ones get listed
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        MetadataService.ConnectedApp connectedApp =
                (MetadataService.ConnectedApp)service.readMetadata('ConnectedApp', new String[] {'Test' }).getRecords()[0];
        system.debug('connectedApp = ' + connectedApp);        
    }

    public static void dumpOrgSettings() {
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery querySettings = new MetadataService.ListMetadataQuery();
        querySettings.type_x = 'Settings';
        queries.add(querySettings);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 37);
        for(MetadataService.FileProperties fileProperty : fileProperties)
            System.debug(fileProperty.fullName);
    }


	/**
	 * Method cloneReport(String sFolderApiName, String sReportApiName, String tFolderApiName, String tReportApiName)
	 * @param sFolderApiName: api name of the (source) folder of the report to clone
	 * @param sReportApiName: api name of the (source) report to clone
	 * @param tFolderApiName: api name of the (target) folder to create the cloned report in
	 * @param tReportApiName: api name of the (target) cloned report 
	 */
	public static void cloneReport(String sFolderApiName, String sReportApiName, String tFolderApiName, String tReportApiName) {
	    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
	    service.SessionHeader = new MetadataService.SessionHeader_element();
	    service.SessionHeader.sessionId = UserInfo.getSessionId();
	
	    // Get the report to clone
	    MetadataService.Report reportToClone = (MetadataService.Report) service.readMetadata('Report', new String[] { sFolderApiName+'/'+sReportApiName }).getRecords()[0];
	
	    // Instanciate a new one to attribute the same metadata from the report to clone
	    MetadataService.Report apexReport = new MetadataService.Report();
	    // Set the cloned report properties from parameters and the source report
	    apexReport.name = reportToClone.name + ' Clone';
	    apexReport.fullName = tFolderApiName + '/' + tReportApiName;
	    apexReport.reportType = reportToClone.reportType;
	    apexReport.description = reportToClone.description;
	    apexReport.format = reportToClone.format;
	    apexReport.filter = reportToClone.filter;
	    apexReport.showDetails = reportToClone.showDetails;
	    apexReport.sortColumn = reportToClone.sortColumn;
	    apexReport.sortOrder = reportToClone.sortOrder;
	    apexReport.groupingsAcross = reportToClone.groupingsAcross;
	    apexReport.groupingsDown = reportToClone.groupingsDown;
	    apexReport.chart = reportToClone.chart;
	    apexReport.timeFrameFilter = reportToClone.timeFrameFilter;
	    apexReport.columns = reportToClone.columns;
	
	    // Create the report clone
	    List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { apexReport });
	
	    // Handle results
	    handleSaveResults(results[0]);
	}
	
    public static void updateDashboard()
    {
        MetadataService.MetadataPort service = createService();

        // Read Dashboard
        MetadataService.Dashboard dashboard =
            (MetadataService.Dashboard) service.readMetadata('Dashboard',
                new String[] { 'MyDashboards/MyDashboard' }).getRecords()[0];
        System.debug('Name ' + dashboard.fullName);
                
        // Update Dashboard
        dashboard.title = 'My updated dashboard';
        dashboard.leftSection.components = new List<MetadataService.DashboardComponent>();
        MetadataService.DashboardComponent newComponent = new MetadataService.DashboardComponent();
        newComponent.autoselectColumnsFromReport = true;
        newComponent.componentType = 'Table';
        newComponent.displayUnits = 'Auto';
        newComponent.drillEnabled = false;
        newComponent.drillToDetailEnabled = false;
        newComponent.indicatorHighColor = '#54C254';
        newComponent.indicatorLowColor = '#C2C254';
        newComponent.indicatorMiddleColor = '#C2C254';
        newComponent.report = 'MyFolder/Accounts';
        newComponent.sortBy = 'RowLabelAscending';
        dashboard.leftSection.components.add(newComponent);
        handleSaveResults(service.updateMetadata(new List<MetadataService.Metadata> { dashboard })[0]);
    }    	
	
    /**
     * Error occured processing component OrgPreference. create() not supported for OrgPreferenceSettings (FIELD_INTEGRITY_EXCEPTION). :-(
     **/
    /*
    public static void enableChatter() {
        MetadataService.MetadataPort service = createService();
        MetadataService.OrgPreferenceSettings orgSettings = new MetadataService.OrgPreferenceSettings();
        orgSettings.preferences = new List<MetadataService.OrganizationSettingsDetail>();
        MetadataService.OrganizationSettingsDetail chatterPref = new MetadataService.OrganizationSettingsDetail();
        chatterPref.settingName = 'ChatterEnabled';
        chatterPref.settingValue = true;
        orgSettings.preferences.add(chatterPref);
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { orgSettings });
        handleSaveResults(results[0]);

    }
    */

    public class MetadataServiceExamplesException extends Exception { }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
    {
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }

    /**
     * Example helper method to interpret a UpsertResult, throws an exception if errors are found
     **/
    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult)
    {
        // Nothing to see?
        if(upsertResult==null || upsertResult.success)
            return;
        // Construct error message and throw an exception
        if(upsertResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + upsertResult.fullName + '.');
            for(MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!upsertResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
}