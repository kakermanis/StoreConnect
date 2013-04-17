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

global class StoreConnectKnowledgeController {
    public String searchTerm {set;get;}    
    public Boolean searchTermDefined {set;get;}
                
    public StoreConnectKnowledgeController() {    
        searchTerm = System.currentPagereference().getParameters().get('searchTerm');                    
        if ('' == searchTerm || searchTerm == null) {
            searchTermDefined = false; 
        } else {
            searchTermDefined = true; 
        }            
    }
    
    
    /**
     *
     * Not a true search function, rather is a page redirect to take advantage
     * of core VF knowledge tags that will perform all complex search queries for us
     *
     */
    public PageReference doSearch() {        
        System.debug('**** The Search term is: ' + searchTerm);        
        searchTermDefined = true;
        PageReference newPage = new PageReference('/apex/StoreConnectKnowledge?searchTerm='+searchTerm);
        return newPage;
    }

    @RemoteAction
    global static KbLoadResult loadKbArticle(String articleId, String articleType) {
        KbLoadResult KbArticle = new KbLoadResult(articleId, articleType);            
        return KbArticle;
    }    
    
    
    @RemoteAction
    public static String emailArticle(String searchTerm, String emailAddress, String articleId, String firstName, String lastName, String mobile) {
        Contact customer;
        Case newCase;
        CaseArticle relatedArticle;
        StoreConnect__c customSettings = StoreConnect__c.getValues('Default');
        
        String result = 'success';
        
        if ('' == firstName || firstName == null) {
            // this is a search just by email address            
            try {
                customer = [select ID, accountId from contact where email =: emailAddress];
            } catch (Exception ex) {
                customer = null;
                result = 'not-found';                
            }          
        } else {
            // insert a whole new contact - shoving them in as a Person account
            // so that I don't need to worry about creating a stubbed account to link them to                        
            RecordType pcRecType = [select id from RecordType where name =: customSettings.Person_Account_Record_Type__c];
            Account newPersonAccount = new Account();

            newPersonAccount.RecordTypeId = pcRecType.id;
            newPersonAccount.firstName = firstName;
            newPersonAccount.lastName = lastName;
            newPersonAccount.PersonEmail = emailAddress;
            newPersonAccount.PersonMobilePhone = mobile;

            insert newPersonAccount;            
            customer = [select id, AccountId from contact where accountId =: newPersonAccount.id];            

            if (customer != null) {
                // Create a case
                // link it to this contact
                // set the subject / desc to the serach term as well as some other pre fabbed header        
                newCase = new Case();
                newCase.contactId = customer.Id;
                newCase.accountId = customer.AccountId;
                newCase.Subject = customSettings.Case_Subject__c + searchTerm;
                newCase.Description = customSettings.Case_Subject__c + searchTerm;
                newCase.status = customSettings.Case_Status__c;
                newCase.type = customSettings.Case_Type__c;
                newCase.Article_PBK_Link__c = getPkbSiteUrl(customSettings) + getArticleUrlName(articleId);            
                insert newCase;
            
                // attach the article to it        
                relatedArticle = new CaseArticle();
                relatedArticle.caseId = newCase.id;
                relatedArticle.KnowledgeArticleId = articleId;
                insert relatedArticle;  
                
                                  
                // Use WorkFlow to take care of all the rest of sending out the email with article       
                    // If Case is closed && Article_PBK_Link__c != empty send out an email.....
            }                                    
        }    
                                                           
        return result;
    }
    
    
    
    private static String getPkbSiteUrl(StoreConnect__c customSettings) {
        Site pkbSite;        
        String siteUrl = 'http://';
        pkbSite = [select id, name, UrlPathPrefix, Subdomain from Site where name =: customSettings.PKB_Site_Name__c];        
        
        siteUrl += pkbSite.Subdomain + '.force.com/';
        
        if (!''.equals(pkbSite.UrlPathPrefix)) {
            siteUrl += pkbSite.UrlPathPrefix + '/';
        }                
        
        siteUrl += 'articles/';
        
        return siteUrl;
    }
    
    
    
    /**
     *
     *
     *
     *
     **/
    private static String getArticleUrlName(String articleId) {
        KnowledgeArticleVersion kbArticle;        
        String articleUrl = '';
        kbArticle = [select id, urlName, ArticleType from KnowledgeArticleVersion where KnowledgeArticleId =: articleId and PublishStatus = 'Online'];                
        articleUrl = kbArticle.ArticleType.left(kbArticle.ArticleType.length() - 5) + '/' + kbArticle.urlName;        
        return articleUrl;
    }
             
    // ------ HELPER CLASSES ------
             
    /**
     *
     * Wrapper and worker class for loading all article types based on selected article
     * Requires both the articleId as well as the Article Type
     *
     **/    
    global class KbLoadResult {                    
        public List<KbSectionDetail> sections = new List<KbSectionDetail>();
        public String articleTitle {set;get;}
        public String articleSummary {set;get;}
        public String articleUrl {set;get;}  
        public String articleId {set;get;}  
        private String PUBLISH_STATUS = 'Online';
        
        // TODO - move into a custom setting so that the language can be configured.....
        private String KB_LANG = 'en_US';         
                        
        public KbLoadResult(String articleId, String articleType) {            
            // Based on the article type, determine the fields to pull using a dynamic SOQL query
            StoreConnectKnowledgeHelper kbHelper = new StoreConnectKnowledgeHelper();
            String kavFields = kbHelper.getFieldsForArticleType(articleType);    
                             
            String kbQuery = 'SELECT ' + kavFields + ' FROM ' + articleType + ' WHERE KnowledgeArticleId =: articleId and PublishStatus =: PUBLISH_STATUS and Language =: KB_LANG';
            sObject loadedKb = Database.query(kbQuery);
            
            // This object will have for sure (since all Articles have the following core fields):
            // Title, Summary, URL Name, Article ID
            
            articleTitle = getDynamicFieldValue(loadedKb, 'Title');           
            articleSummary = getDynamicFieldValue(loadedKb, 'Summary');
            articleUrl = getDynamicFieldValue(loadedKb, 'URLName');
            this.articleId = articleId;            

            // Based on the article Type, you now need to pick apart the individual fields
            // and load them into a KB Section Detail
            sections.addAll(extractSectionDetails(loadedKb, articleType, kbHelper));                      
        }   
        
        
        /*
         *
         * Provides a wrapper class to abstract the differences between 
         * the various Article Types and their custom sections/fields
         *
         **/
        private List<KbSectionDetail> extractSectionDetails(sObject loadedKb, String ArticleType, StoreConnectKnowledgeHelper kbHelper) {                        
            List<KbSectionDetail> kbSections = new List<KbSectionDetail>();                        
            // grab list of of field set members for this particular Article Type            
            List<Schema.FieldSetMember> kbFields = kbHelper.getFieldMemberSetForArticleType(ArticleType);
            
            // Based on the article type we need to look up whether the fields within the FieldSet
            // are core or custom fields as we are only interested in Custom ones
            Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();                         
            Schema.sObjectType sObjType = globalDescription.get(ArticleType);
            
            Schema.DescribeSObjectResult describeResult = sObjType.getDescribe();  
            Map<String , Schema.SObjectField> mapFieldList = describeResult.fields.getMap();
                        
            // check if the field within the FieldSet is custom and 
            // if it is then create a new section for it            
            for(Schema.FieldSetMember curField : kbFields) {
                Schema.SObjectField field = mapFieldList.get(curField.getFieldPath());                        
                if (field.getDescribe().isCustom()) {                    
                    KbSectionDetail newSection = new KbSectionDetail(field.getDescribe().getLabel(), (String)loadedKb.get(curField.getFieldPath()));
                    kbSections.add(newSection);
                }
            }                                  
            return kbSections;
        }
        
        
        private String getDynamicFieldValue(sObject loadedKb, String fieldName) {
            String fieldValue = '';            
            if ( loadedKb.get(fieldName) != null ) {
                fieldValue = (String)loadedKb.get(fieldName);
            }                                     
            return fieldValue;
        }
    }  // END KbLoadResult class

    
    /**
     *
     * Represents a single KB arcticle section regardless of Article Type
     * This allows for a singular and simple template to be used on the UI
     *
     **/          
    global class KbSectionDetail {        
        public KbSectionDetail(String sectionHeader, String sectionContent) {
            this.sectionHeader = sectionHeader;
            this.sectionContent = sectionContent;
        }    
        public String sectionHeader {set;get;}
        public String sectionContent {set;get;}    
    }    // END KbSectionDetail class       
}