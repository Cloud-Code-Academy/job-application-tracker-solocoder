import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
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
        let salary = Number(this.annualSalary);
        let federal = await calculateFederalTax({ annualSalary : this.annualSalary });
        let medical = await calculateMedicareTax ({ annualSalary : this.annualSalary });
        let social = await calculateSocialSecurityTax({ annualSalary : this.annualSalary });
        this.takeHomePay = Math.round(salary - (federal + medical + social));
        }
        catch (error) {
        console.log('Salary:', salary);
        console.log('federalTaxAmount:', federal);
        console.log('medicalTaxAmount:', medical);
        console.log('socialTaxAmount:', social);
        console.log('Take Home:', this.takeHomePay);
        }  
    }
    
    
    async calFederalTax(){
        await calculateFederalTax({ annualSalary : this.annualSalary })
            .then(result => {
                this.federalTaxAmount = Math.round(result);
            })
            .catch(error => {
                console.log('Error ::: ' + error);
            });
    }

    calcMedicareTax(){
        calculateMedicareTax({ annualSalary : this.annualSalary })
            .then(result => {
                this.medicareTaxAmount = Math.round(result);
            })
            .catch(error => {
                console.log('Error ::: ' + error);
            });
    }

    calcSocialSecurityTax(){
        calculateSocialSecurityTax({ annualSalary : this.annualSalary })
            .then(result => {
                this.socialSecurityAmount = Math.round(result);
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