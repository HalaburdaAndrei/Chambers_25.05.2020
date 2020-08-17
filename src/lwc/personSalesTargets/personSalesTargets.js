import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserSalesTargets from '@salesforce/apex/PersonSalesTargets_CTRL.getUserSalesTargets'
import generateDates from '@salesforce/apex/PersonSalesTargets_CTRL.generateDates'
import upsertSalesTargets from '@salesforce/apex/PersonSalesTargets_CTRL.upsertSalesTargets'

export default class PersonSalesTargets extends LightningElement {
  salesTargets
  columns
  @track tableData
  isReadyData = false
  selectedYear = new Date().getFullYear()
  get availableYears() {
    let currYear = new Date().getFullYear()
    let nextYear = currYear + 1
    return [
      { label: `${currYear.toString()} - ${nextYear.toString()}`, value: currYear },
      { label: `${nextYear.toString()} - ${(nextYear + 1).toString()}`, value: nextYear }
    ]
  }

  /**
   * Load data from backend
   */

  connectedCallback() {
    this.loadData()
  }

  loadData() {
    this.isReadyData = false
    Promise.all([
      getUserSalesTargets({ 'selectedYear': this.selectedYear }),
      generateDates({ 'selectedYear': this.selectedYear })
    ]).then(result => {
      let [salesTargets, dates] = result
      this.salesTargets = salesTargets
      this.columns = this.generateColumns(dates)
      this.tableData = this.generateTableData(salesTargets, dates)
      this.isReadyData = true
    }).catch(err => {
      this.showToast('Error', err.body.message, 'error')
      this.isReadyData = true
    })
  }

  generateTableData(salesTargets, dates) {
    let tableData = []
    for (let userId in salesTargets) {
      let tableRow = {}
      tableRow.userName = salesTargets[userId].userName
      tableRow.cellBorderCssClass = 'slds-border_right'
      dates.forEach(date => {
        tableRow.userId = userId
        tableRow[date] = salesTargets[userId][date] ? salesTargets[userId][date].Target__c : null
      });
      tableData.push(tableRow)
    }
    return tableData
  }

  generateColumns(dates) {
    let columns = [{
      label: 'Sales Person',
      fieldName: 'userName',
      editable: false,
      initialWidth: 120,
      cellAttributes: { 
        class: { fieldName: 'cellBorderCssClass' }
      }
    }]
    return columns.concat(
      dates.map(date => {
        return {
          label: this.dateToStr(date),
          fieldName: date,
          type: 'currency',
          editable: true,
          cellAttributes: { 
            class: { fieldName: 'cellBorderCssClass' } 
          }
        }
      })
    )
  }

  /**
   * Save data in dataBase 
   */

  handleSave(event) {
    this.isReadyData = false
    event.preventDefault()
    let dataToUpdate = this.makeListSalesTargToUpds(event);
    upsertSalesTargets(
      { 'salesTargets': dataToUpdate }
    ).then(() => {
      this.loadData();
      this.showToast('Success', 'Person Sales Targets have been updated.', 'success')
    }).catch(err => {
      let message = ''
      if (err.body.pageErrors)
        err.body.pageErrors.forEach(error => message += `${error.message}.\n`)
      else
        message = err.body.message
      this.showToast('Error', message, 'error')
      this.isReadyData = true
    })
  }

  makeListSalesTargToUpds(event) {
    let dataToUpdate = []
    event.detail.draftValues.forEach(sts => {
      let targetByUser = this.salesTargets[sts.userId]
      for (let key in sts) {
        if (key != 'userId' && targetByUser[key]) {
          targetByUser[key].sobjectType = 'Sales_Target__c'
          targetByUser[key].Target__c = +sts[key]
          dataToUpdate.push(targetByUser[key])
        } else if (key != 'userId' && !targetByUser[key]) {
          dataToUpdate.push({
            sobjectType: 'Sales_Target__c',
            Sales_Person__c: sts.userId,
            Date__c: key,
            Target__c: +sts[key]
          })
        }
      }
    })
    return dataToUpdate;
  }

  /**
   * Select Year 
   */

  handleSelectYear(event) {
    this.selectedYear = +event.detail.value;
    this.loadData()
  }

  /**
   * Helper Methods 
   */

  dateToStr(date) {
    return new Date(date).toLocaleDateString('en-US', { year: '2-digit', month: 'short' })
  }

  showToast(Title, Message, Variant) {
    const event = new ShowToastEvent({
      title: Title,
      message: Message,
      variant: Variant
    });
    this.dispatchEvent(event);
  }
}