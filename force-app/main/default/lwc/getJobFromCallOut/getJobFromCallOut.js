import { LightningElement, track } from 'lwc';
import getJobFromJooble from '@salesforce/apex/JobHelper.getJobFromJooble';
export default class GetJobFromCallOut extends LightningElement {

keyword;
location;
page;
resultsOnPage;
minSalary;
@track showSuccess = false;

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
            await getJobFromJooble({keyword: this.keyword, location: this.location, page: this.page, resultsOnPage: this.resultsOnPage, minSalary: this.minSalary})
            .then(result => {
                this.showSuccess = true;
            })
            .catch (error => {
                console.error('Error::: ' + error);
        });
    }
}