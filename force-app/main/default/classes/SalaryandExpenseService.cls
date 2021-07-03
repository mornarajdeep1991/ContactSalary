public class SalaryandExpenseService {
    public static void afterInsertRecords(List<SalaryandExpenses__c> newList, Map<Id, SalaryandExpenses__c> newMap){
        set<Id> accountIds = new set<Id>();
        set<Id> contactIds = new set<Id>();
        system.debug('newMap.values()'+newMap.values());
        for(SalaryandExpenses__c consal : newMap.values()){
            contactIds.add(consal.contact__c);
        }
        if(contactIds.isEmpty()){
            return;
        }
        for(Contact c : [select accountid from contact where Id In:contactIds]){
            accountIds.add(c.AccountId);
        }
        if(!accountIds.isEmpty()){
            List<AggregateResult> aggrResult = [SELECT SUM(Salary__c)totalsal,SUM(MonthlyExpenses__c)totalexp,AVG(MonthlyExpenses__c)avgexp FROM SalaryandExpenses__c  
                                                WHERE contact__r.AccountId In:accountIds];
            
            // cannot create map as it is an aggregate query.
            // As bulkification, for in a for is required upto one level.
            // As List will comes always in an order
            
            List<Account> accList = new List<Account>();
            if(!aggrResult.isEmpty()){
                for(Account a : [select id from account where id In:accountIds]){
                    for(AggregateResult agr:aggrResult){
                        a.TotalSalary__c = Decimal.valueOf(String.valueOf(agr.get('totalsal'))); 
                        a.TotalExpenses__c= Decimal.valueOf(String.valueOf(agr.get('totalexp')));
                        a.AverageExpenses__c= Decimal.valueOf(String.valueOf(agr.get('avgexp')));
                        accList.add(a);
                    }
                }
                if(!accList.isEmpty()){
                    update accList;
                }
               
            }
            
            
        }        }
    
}