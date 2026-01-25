/**
 * This class is used for LWC importing apex classes for tax cacluation function
 */
public with sharing class LWC_Controller {
    /**
    * This method calls the method in application helper to calculate federal tax on annual salary
    * @param annualSalary annualSalary the annual salary amount used for calculating taxes.
    * @return Decimal returns the calculated tax amount.
    */
    @AuraEnabled
    public static Decimal calculateFederalTax(Decimal annualSalary){
        try {
            return ApplicationHelper.calculateFederalTax(annualSalary);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     /**
    * This method calls the method in application helper to calculate medicare tax on annual salary
    * @param annualSalary annualSalary the annual salary amount used for calculating taxes.
    * @return Decimal returns the calculated tax amount.
    */
    @AuraEnabled
    public static Decimal calculateMedicareTax(Decimal annualSalary){
        try {
            return ApplicationHelper.calculateMedicareTax(annualSalary);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
     /**
    * This method calls the method in application helper to calculate social security on annual salary
    * @param annualSalary annualSalary the annual salary amount used for calculating taxes.
    * @return Decimal returns the calculated tax amount.
    */
    @AuraEnabled
    public static Decimal calculateSocialSecurityTax(Decimal annualSalary){
        try {
            return ApplicationHelper.calculateSocialSecurityTax(annualSalary);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}