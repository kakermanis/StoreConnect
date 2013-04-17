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

global class StoreConnectController {
    private static String VF_PAGE_PREFIX = 'StoreConnect';
    public String currentPageName {set;get;}    
    public StoreConnect__c customSettings {set;get;}
    
    
    public String getSpinnerColour() {
        if (customSettings == null ) {
            setupCustomSettings();   
        }          
        return customSettings.Navbar_Top_Colour__c;        
    }


    public StoreConnectController(StoreConnectKnowledgeController controller) {
         determinePage();
         setupCustomSettings();
    }
    
    public StoreConnectController() {
         determinePage();
         setupCustomSettings();
    }
    
    private void setupCustomSettings() {
        customSettings = StoreConnect__c.getValues('Default');
        if(customSettings == null) {
            System.debug('The custom settings came back null!!!');
        }
    }
    
    
    /**
     *
     * Uses a naming convention (Assumes all VF pages start with StoreConnect) to determine the current page that the user is on
     * and allows automatic highlighting of the current page within the NavBar
     *
     **/
    public void determinePage() {
        String pageUrl = ApexPages.currentPage().getUrl();
        
        Integer endPageName = pageUrl.length();
        if (pageUrl.indexOf('?') != -1) {
            // This has additional URL parameters
            endPageName = pageUrl.indexOf('?');
        }
        
        String currentPage = pageUrl.subString(pageUrl.lastIndexOf('/') +1, endPageName);
        currentPageName = currentPage.subString(VF_PAGE_PREFIX.length(),currentPage.length());                 
        System.debug('****** In RetailConnect controller - current page is: ' + ApexPages.currentPage() + ' Page name is: ' + currentPage + ' Trimmed Page name is: ' + currentPageName);               
    }
    
    private static void setupPage() {
        PageReference pageRef = new PageReference('/apex/StoreConnectChatter');                       
        Test.setCurrentPage(pageRef);                      
    }
    

    private static testmethod void TestExtensionController() {
        setupPage();
        StoreConnectKnowledgeController extensionsCtrl = new StoreConnectKnowledgeController();  
        
        StoreConnectController ctrl = new StoreConnectController(extensionsCtrl);            
    }    
    
    private static testmethod void TestSpinnerColour() {
        setupPage();
        StoreConnectController ctrl = new StoreConnectController();
        //String spinnerColour = ctrl.getSpinnerColour();
        
        //System.AssertNotEquals(null, spinnerColour);
    }         
}