public with sharing class LWC_Controller {
    @AuraEnabled
    public static Decimal calculateFederalTax(Decimal annualSalary){
        try {
            return ApplicationHelper.calculateFederalTax(annualSalary);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Decimal calculateMedicareTax(Decimal annualSalary){
        try {
            return ApplicationHelper.calculateMedicareTax(annualSalary);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Decimal calculateSocialSecurityTax(Decimal annualSalary){
        try {
            return ApplicationHelper.calculateSocialSecurityTax(annualSalary);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}