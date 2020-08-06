import { LightningElement, track } from 'lwc';
import getUserSalesTargets from '@salesforce/apex/PersonSalesTargets_CTRL.getUserSalesTargets'
import generateDates from '@salesforce/apex/PersonSalesTargets_CTRL.generateDates'
import upsertSalesTargets from '@salesforce/apex/PersonSalesTargets_CTRL.upsertSalesTargets'

export default class PersonSalesTargets extends LightningElement {
  salesTargets
  columns
  @track tableData
  isReadyData = false
  selectedYear = new Date().getFullYear()
  get availableYears(){
    let currYear = new Date().getFullYear()
    let nextYear = currYear + 1
    return [
      { label: `${currYear.toString()} - ${nextYear.toString()}`, value: currYear},
      { label: `${nextYear.toString()} - ${(nextYear + 1).toString()}`, value: nextYear}
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
      getUserSalesTargets({'selectedYear': this.selectedYear}),
      generateDates({'selectedYear': this.selectedYear})
    ]).then(result => {
      let [salesTargets, dates] = result
      this.salesTargets = salesTargets
      this.columns = this.generateColumns(dates)
      this.tableData = this.generateTableData(salesTargets, dates)
      this.isReadyData = true
    }).catch(err => {
      //TODO: Implement Error notification
    })
  }

  generateTableData(salesTargets, dates) {
    let tableData = []
    for (let userId in salesTargets) {
      let tableRow = {}
      tableRow.userName = salesTargets[userId].userName
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
      initialWidth: 120
    }]
    return columns.concat(
      dates.map(date => {
        return {
          label: this.dateToStr(date),
          fieldName: date,
          type: 'currency',
          editable: true
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
      {'salesTargets': dataToUpdate}
    ).then(result => {
      this.loadData();
    }).catch(err => {
      // TODO: Implement error notification
    })
  }

  makeListSalesTargToUpds(event) {
    let dataToUpdate = []
    event.detail.draftValues.forEach(sts => {
      let targetByUser = this.salesTargets[sts.userId]
      for (let key in sts) {
        if (key != 'userId') {
          if (targetByUser[key]) {
            targetByUser[key].sobjectType = 'Sales_Target__c'
            targetByUser[key].Target__c = +sts[key]
            dataToUpdate.push(targetByUser[key])
          } else {
            dataToUpdate.push({
              sobjectType: 'Sales_Target__c',
              Sales_Person__c: sts.userId,
              Date__c: key,
              Target__c: +sts[key]
            })
          }
        }
      }
    })
    return dataToUpdate;
  }

/**
 * Select Year 
 */

  handleSelectYear(event){
    this.selectedYear = +event.detail.value;
    this.loadData()
  }

/**
 * Helper Methods 
 */  

  dateToStr(date) {
    return new Date(date).toLocaleDateString('en-US', { year: '2-digit', month: 'short' })
  }
}