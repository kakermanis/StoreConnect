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

public class StoreConnectKnowledgeHelper {

    private Map<String, List<Schema.FieldSetMember>> knowledgeFields;
    private static String ALERT = 'Alert__kav';
    private static String FAQ = 'FAQ__kav';
    private static String HOW_TO = 'How_To__kav';
    private static String NETWORK = 'Network_Upgrade__kav';
    private static String ORDER = 'Order_Support__kav';
    private static String TECH = 'Technical__kav';
    private static String GENERAL_QnA = 'General_QnA__kav';
    
    
    public StoreConnectKnowledgeHelper() {
        loadFieldMap();
    }
    
    
    /**
     *
     * Load up and map the various Article Types (based on API Name) to 
     * their corresponding Field Sets.  Currently includes all Article Types within the SDO as of Jan 2013
     *
     **/
    private void loadFieldMap() {    
        knowledgeFields = new Map<String, List<Schema.FieldSetMember>>();
        knowledgeFields.put(GENERAL_QnA,(Schema.SObjectType.General_QnA__kav.fieldSets.STORE_CONNECT_GENERAL_FAQ.getFields()));        
        
/*        
        knowledgeFields.put(ALERT,(Schema.SObjectType.alert__kav.fieldSets.STORE_CONNECT_ALERT.getFields()));
        knowledgeFields.put(FAQ,(Schema.SObjectType.FAQ__kav.fieldSets.STORE_CONNECT_FAQ.getFields()));
        knowledgeFields.put(HOW_TO,(Schema.SObjectType.how_to__kav.fieldSets.STORE_CONNECT_HOW_TO.getFields()));
        knowledgeFields.put(ORDER,(Schema.SObjectType.order_support__kav.fieldSets.STORE_CONNECT_ORDER.getFields()));
        knowledgeFields.put(NETWORK,(Schema.SObjectType.network_upgrade__kav.fieldSets.STORE_CONNECT_NETWORK.getFields()));
        knowledgeFields.put(TECH,(Schema.SObjectType.technical__kav.fieldSets.STORE_CONNECT_TECH.getFields()));
*/        
    }
    
    
    /*
     *
     * Creates a CSV based on the fieldset that is passed to it
     *
     */
    private String parseFieldSetMembers(List<Schema.FieldSetMember> fields) {
        String fieldList = '';    
        if (fields != null) {
            for(Schema.FieldSetMember curMemb : fields) {
                fieldList += curMemb.getFieldPath() + ',';
            }                                
            fieldList = fieldList.removeEnd(',');                
        }               
        return fieldList;
    }
    
    
    /**
     *
     * Returns a comma separated list of Article fields specified in the 
     * STORE_CONNECT_XXX field sets loaded within the constructor
     *
     **/
    public String getFieldsForArticleType(String ArticleName) {        
        return parseFieldSetMembers(knowledgeFields.get(ArticleName));    
    } 
    
    
    /**
     *
     * Returns a FieldMemberSet object of Article fields specified in the 
     * STORE_CONNECT_XXX field sets loaded within the constructor
     *
     **/    
    public List<Schema.FieldSetMember> getFieldMemberSetForArticleType(String ArticleName) {
        return knowledgeFields.get(ArticleName);    
    }   
    
    
   static testMethod void TestGetFieldsForArticleType() {
        StoreConnectKnowledgeHelper helper = new StoreConnectKnowledgeHelper();
        helper.getFieldsForArticleType('Junk');                       
    }
    
   static testMethod void TestGetFieldsMemberSetForArticleType() {
        StoreConnectKnowledgeHelper helper = new StoreConnectKnowledgeHelper();        
        helper.getFieldMemberSetForArticleType('Junk');        
    }    
}