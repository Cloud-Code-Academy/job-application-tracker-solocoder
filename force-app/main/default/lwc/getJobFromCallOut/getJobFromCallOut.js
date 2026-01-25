import { LightningElement, api } from 'lwc';
import getJobFromJobble from '@salesforce/apex/JobHelper.getJobFromJobble';
export default class GetJobFromCallOut extends LightningElement {

keyword = 'Salesforce Developer';
location = 'Seattle, WA';
page = 5;
resultsOnPage = 2;
minSalary = 90000;

    changeHandler(event) {
        this.keyword = event.target.value;
    }

    changeHandler2(event) {
        this.location = event.target.value;
    }

    changeHandler3(event) {
        this.page = event.target.value;
    }

    changeHandler4(event) {
        this.resultsOnPage = event.target.value;
    }

    changeHandler5(event) {
        this.minSalary = event.target.value;
    }


    async handleOnclick() {
            await getJobFromJobble({keyword: this.keyword, location: this.location, page: this.page, resultsOnPage: this.resultsOnPage, minSalary: this.minSalary})
            .then(() => {
                console.log('Record created sucessfully');
            })
            .catch (error => {
                console.error('Error::: ' + error);
        });
    }
}