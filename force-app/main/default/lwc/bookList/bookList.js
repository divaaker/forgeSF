import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBooks from '@salesforce/apex/BookController.getBooks';
import createBook from '@salesforce/apex/BookController.createBook';

const COLUMNS = [
    { label: 'Title', fieldName: 'Title__c' },
    { label: 'Author', fieldName: 'Author__c' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Rating', fieldName: 'Rating__c', type: 'number' },
    { label: 'Finished', fieldName: 'DateFinished__c', type: 'date-local' }
];

const STATUS_OPTIONS = [
    { label: 'Wishlist', value: 'Wishlist' },
    { label: 'Reading', value: 'Reading' },
    { label: 'Completed', value: 'Completed' }
];

export default class BookList extends LightningElement {
    columns = COLUMNS;
    statusOptions = STATUS_OPTIONS;
    title = '';
    author = '';
    status = 'Wishlist';
    wiredResult;

    @wire(getBooks)
    wired(result) {
        this.wiredResult = result;
    }

    get books() {
        return this.wiredResult?.data ?? [];
    }

    get error() {
        return this.wiredResult?.error;
    }

    handleChange(event) {
        this[event.target.name] = event.target.value;
    }

    async handleCreate() {
        try {
            await createBook({ title: this.title, author: this.author, status: this.status });
            this.title = '';
            this.author = '';
            this.dispatchEvent(new ShowToastEvent({ title: 'Book added', variant: 'success' }));
            await refreshApex(this.wiredResult);
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: e?.body?.message ?? e.message,
                variant: 'error'
            }));
        }
    }
}