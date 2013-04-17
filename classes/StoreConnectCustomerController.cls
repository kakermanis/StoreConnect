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

public class StoreConnectCustomerController {

    public StoreConnectCustomerController() {

    }
    
    /**
     *
     * SOSL search to find contact records - at time of writing this only searches the Contact object
     * and does not cater for Account searches so may not handle Person Accounts very well
     *
     **/            
    @RemoteAction
    public static ContactSearchWrapper doSearch(String searchTerm) {        
        System.debug('**** The Search term is: ' + searchTerm);
        List<Contact> foundContacts = new List<Contact>();
        ContactSearchWrapper searchResults;
                        
        // Do a SOSL query on the serach term
        // look at both accounts as well as contacts???? for now just looking at contacts.....                
        // , Account (Id, firstName, lastName, email)
        String soslQuery = ' FIND {*' + searchTerm +  '*} IN ALL FIELDS RETURNING Contact (Id, firstName, lastName, email)';
        List<List <sObject>> myQuery = search.query(soslQuery); 
        
        // The first one should be contacts... Ignoring accounts for now....       
        foundContacts = myQuery.get(0);        
        searchResults = new ContactSearchWrapper(myQuery.get(0));        
        return searchResults;
    }
    
    
    /**
     *
     * Loads in the contact record based on the passed in contact ID
     * ContactWrapper is a construct that provides logical data separation into
     * relevant content blocks allowing for changes in layout for the various 
     * contact record data sets
     *
     **/    
    @RemoteAction
    public static ContactWrapper loadContactRecord(String contactId) {
        ContactWrapper loadedContact = new ContactWrapper(contactId);                                    
        return loadedContact;
    }
    
               
    /**
     *
     * Created a wrapper so that it is easier to take apart the return JSON 
     * string as it will be sorted into logical categories.
     * Even though each of the logical sections is only meant to hold a single contact dataset
     * it has been implemented as a List to cater for how iCanHaz/Mustashe caters for Sections and sets
     *
     **/
    public class ContactWrapper {
        public List<Contact> basicInfo {set;get;}
        public List<Contact> notes {set;get;}
        public List<Contact> socialInfo {set;get;}
                
        public ContactWrapper(String contactId) {        
            // Grab all the fields from the various Field Sets...
            // STORE_CONNECT_XXX -- CONTACT_BASIC_INFO / CONTACT_NOTES / CONTACT_SOCIAL
            String notesQuery;
            String socialInfoQuery;
            
            basicInfo = new List<Contact>();
            notes = new List<Contact>();
            socialInfo = new List<Contact>();
            
            basicInfo.add(Database.query(buildContactQuery(Schema.SObjectType.Contact.fieldSets.STORE_CONNECT_CONTACT_BASIC_INFO.getFields(), contactId)));
            
            notesQuery = buildContactQuery(Schema.SObjectType.Contact.fieldSets.STORE_CONNECT_CONTACT_NOTES.getFields(), contactId);            
            if (notesQuery != null) {
                notes.add(Database.query(notesQuery));            
            }
            
            socialInfoQuery = buildContactQuery(Schema.SObjectType.Contact.fieldSets.STORE_CONNECT_CONTACT_SOCIAL.getFields(), contactId);
            if (socialInfoQuery != null) {
                socialInfo.add(Database.query(socialInfoQuery));
            }                                               
        }
        
        
        // ------- MISC Utility classes for building query strings and pulling apart field set lists
                
        private String buildContactQuery(List<Schema.FieldSetMember> fields, String contactId) {                
            String queryString = null;
            
            if (!fields.isEmpty()) {
                queryString = 'SELECT ' + parseFieldSetMembers(fields) + ' FROM Contact where Id =: contactId';
            }                                     
            return queryString;
        }
                
        private String parseFieldSetMembers(List<Schema.FieldSetMember> fields) {
            String fieldList = '';           
            for(Schema.FieldSetMember curMemb : fields) {
                fieldList += curMemb.getFieldPath() + ',';
            }                                
            fieldList = fieldList.removeEnd(',');        
            return fieldList;
        }            
    }
    
    
    /*
     *
     * Wrapper class for the Contact list returned by the SOSL search
     * This is necessary due to the way that iCanHaz/Mustache needs to handle repeating sections
     *
     **/
    public class ContactSearchWrapper {
        public List<Contact> contacts;
        
        public ContactSearchWrapper(List<Contact> contacts) {
            this.contacts = contacts;
        }        
    }      
    
    
    static testMethod void TestSearch() { 
        StoreConnectCustomerController.doSearch('Junk');
    }
    
    static testMethod void TestLoad() {
        Account testAccount = new Account();
        testAccount.name = 'Test Account';
        insert testAccount;
    
        Contact newContact = new Contact();
        newContact.firstName = 'Test Person';
        newContact.LastName = 'Test Person';
        newContact.AccountId = testAccount.Id;
        
        insert newContact;
        
        
        StoreConnectCustomerController.loadContactRecord(String.valueOf(newContact.Id));
        
    
    }
            
}