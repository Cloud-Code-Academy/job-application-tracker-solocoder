import { LightningElement, api } from 'lwc';
import calculateFederalTax from '@salesforce/apex/LWC_Controller.calculateFederalTax';
import calculateMedicareTax from '@salesforce/apex/LWC_Controller.calculateMedicareTax';
import calculateSocialSecurityTax from '@salesforce/apex/LWC_Controller.calculateSocialSecurityTax';
export default class TakeHomePayCalculator extends LightningElement {
    
    annualSalary;
    federalTaxAmount;
    medicareTaxAmount;
    socialSecurityAmount;
    takeHomePay;
    semiAnnualTakeHomePay;
    monthlyTakeHomePay;
    biWeeklyTakeHomePay;

    async calculateTakeHomePay(){
        try { 
        let salary = Number(this.annualSalary).toFixed(2);
        let federal = await calculateFederalTax({ annualSalary : this.annualSalary });
        let medical = await calculateMedicareTax ({ annualSalary : this.annualSalary });
        let social = await calculateSocialSecurityTax({ annualSalary : this.annualSalary });
        this.takeHomePay = (salary - (federal + medical + social)).toFixed(2);
        this.semiAnnualTakeHomePay = (this.takeHomePay/2).toFixed(2);
        this.monthlyTakeHomePay = (this.takeHomePay/12).toFixed(2);
        this.biWeeklyTakeHomePay = (this.takeHomePay/26).toFixed(2);
        }
        catch (error) {
        console.log('Salary:', salary);
        console.log('federalTaxAmount:', federal);
        console.log('medicalTaxAmount:', medical);
        console.log('socialTaxAmount:', social);
        console.log('Take Home:', this.takeHomePay);
        }  
    }
    
    
    calFederalTax(){
        calculateFederalTax({ annualSalary : this.annualSalary })
            .then(result => {
                this.federalTaxAmount = (result).toFixed(2);
            })
            .catch(error => {
                console.log('Error ::: ' + error);
            });
    }

    calcMedicareTax(){
        calculateMedicareTax({ annualSalary : this.annualSalary })
            .then(result => {
                this.medicareTaxAmount = (result).toFixed(2);
            })
            .catch(error => {
                console.log('Error ::: ' + error);
            });
    }

    calcSocialSecurityTax(){
        calculateSocialSecurityTax({ annualSalary : this.annualSalary })
            .then(result => {
                this.socialSecurityAmount = (result).toFixed(2);
            })
            .catch(error => {
                console.log('Error ::: ' + error);
            });
    }

    changeHandler(event) {
        this.annualSalary = event.target.value;
    }

    onClick() {
        this.calFederalTax();
        this.calcMedicareTax();
        this.calcSocialSecurityTax();
        this.calculateTakeHomePay();
    }



}