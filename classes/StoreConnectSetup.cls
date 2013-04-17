// Copyright 2013, Kevin Akermanis - Sales Engineering, Salesforce.com Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the salesforce.com nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

public class StoreConnectSetup {
    private static String CUSTOM_SETTING_NAME = 'Default';
    public StoreConnect__c customSettings {set;get;}
    public StaticResource loginIcon {set;get;}
    public StaticResource favIcon {set;get;}    
    public StaticResource appIcon {set;get;}    
    public StaticResource searchIcon {set;get;}    
    public StaticResource customerIcon {set;get;}    
    public List<SelectOption> publicSites {set;get;}
    public List<SelectOption> personAccountRecTypes {set;get;}    
    public List<SelectOption> caseStatus {set;get;}
    public List<SelectOption> caseTypes {set;get;}
                
    public StoreConnectSetup() {
        setupIconLinks();
        setupQueriedDropDowns();
        setupMetaDescribeDropDowns();              
    }
    
    
    private void setupMetaDescribeDropDowns() {
        caseStatus = new List<SelectOption>();
        caseTypes = new List<SelectOption>();
                
        Schema.DescribeFieldResult caseStatusFieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> caseStatusChoices = caseStatusFieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : caseStatusChoices) {
          caseStatus.add(new SelectOption(f.getLabel(), f.getLabel()));
        }   
                        
        Schema.DescribeFieldResult caseTypeFieldResult = Case.type.getDescribe();
        List<Schema.PicklistEntry> caseTypeChoices = caseTypeFieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : caseTypeChoices) {
          caseTypes.add(new SelectOption(f.getLabel(), f.getLabel()));
        }                     
    }
    
    private void setupQueriedDropDowns() {
        publicSites = new List<SelectOption>();        
        for(Site curSite : [select ID, name from Site where Status = 'Active']) {            
            publicSites.add(new SelectOption( curSite.name, curSite.name ));            
        }
                                
        personAccountRecTypes = new List<SelectOption>();                         
        for (RecordType curRecType : [select ID, name from RecordType where SobjectType = 'Account' and isPersonType = true and IsActive = true]) {
            personAccountRecTypes.add(new SelectOption( curRecType.name, curRecType.name ));            
        }    
    }
    
    private void setupIconLinks() {
        loginIcon  = [select ID from staticResource where name = 'StoreConnect_login_logo'];
        favIcon = [select ID from staticResource where name = 'StoreConnect_Favico'];
        appIcon = [select ID from staticResource where name = 'StoreConnectAppIcon'];
        searchIcon = [select ID from staticResource where name = 'STORE_CONNECT_SEARCH_ICON'];
        customerIcon = [select ID from staticResource where name = 'STORE_CONNECT_CUSTOMER_ICON'];    
    }


    public PageReference checkDefaultSetup() {        
        customSettings = StoreConnect__c.getValues(CUSTOM_SETTING_NAME);
        if (customSettings == null) {
            // Their instance doesn't have a default bunch of custom settings so create one for them
            customSettings = new StoreConnect__c();            
            customSettings.name = CUSTOM_SETTING_NAME;
            insert customSettings;
        }    
        return null;
    }            
    
    /**
     *
     *
     *
     *
     **/
    public PageReference saveCustomisations() {        
        update customSettings;
        return null;
    }
    
    
    
    static testMethod void TestDefaultCustomSettings() {
        StoreConnectSetup ctrl = new StoreConnectSetup();        
        System.assertEquals(null, ctrl.checkDefaultSetup(), 'This should always return null');    
    }
    
    static testMethod void TestFullConstructor() {
        StoreConnectSetup ctrl = new StoreConnectSetup();   
        ctrl.checkDefaultSetup();        
        System.assertNotEquals(null, ctrl.customSettings, 'There should at least be a default object created');            
    }    
        
    

}