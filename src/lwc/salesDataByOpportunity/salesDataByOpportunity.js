import { LightningElement, api, wire, track } from 'lwc';
import getData from '@salesforce/apex/SalesDataByOpportunity_CTRL.getData'
import createNewOppProduct from '@salesforce/apex/SalesDataByOpportunity_CTRL.createNewOppProduct'

const TITLE_CURRENT_YEAR = 'Current FY sales data for HO'
const TITLE_LAST_YEAR = 'Last FY sales data for HO'
const COLL_WIDTH_EXTRA_LARGE = 240
const COLL_WIDTH_LARGE = 200
const COLL_WIDTH_SMALL = 80
export default class SalesDataByOpportunity extends LightningElement {
  // Properties
  @api oppId = '0061l00000JmP6gAAF'
  @api isCurrentYear
  @track gridData
  timeOut
  isReady = false
  get titleForYear(){
    return this.isCurrentYear ? TITLE_CURRENT_YEAR : TITLE_LAST_YEAR
  }
  get isData(){
    if(!this.gridData || this.gridData.length == 0) return false
    else return true
  }
  
  @track gridColumns = [
    {
      type: 'text',
      fieldName: 'catalogName',
      label: 'Publication',
      initialWidth: COLL_WIDTH_EXTRA_LARGE,
      wrapText: true,
      cellAttributes:{class:"slds-tree__item table-th"}
    },
    {
      type: 'button',
      fieldName: 'add',
      initialWidth: COLL_WIDTH_SMALL,
      typeAttributes: {
        name: 'add', 
        title: 'Add',
        label:'Add',
        alternativeText:'Add',
        variant: 'brand',
        class: {fieldName: 'isbutton'}
      }
    },
    {
      type: 'text',
      fieldName: 'productName',
      label: 'Product',
      initialWidth: COLL_WIDTH_LARGE,
      wrapText: true
    },
    {
      type: 'number',
      fieldName: 'quantity',
      label: 'Qty',
      initialWidth: COLL_WIDTH_SMALL
    },
    {
      type: 'number',
      fieldName: 'totalPrice',
      label: 'Total Price',
    },
    {
      type: 'text',
      fieldName: 'signer',
      label: 'Signer',
      wrapText: true
    },
    {
      type: 'date',
      fieldName: 'closeDate',
      label: 'Close Date',
    },
    {
      type: 'text',
      fieldName: 'salesPerson',
      label: 'Sales Person',
      wrapText: true
    },
    {
      type: 'url',
      fieldName: 'opportunityUrl',
      label: 'Opp id',
      typeAttributes: {
        label: { fieldName: 'opportunityId' },
        target : '_blank'
      },
  },
    {
      type: 'text',
      fieldName: 'relatedOrg',
      label: 'Related Org',
      wrapText: true
    },
    {
      type: 'text',
      fieldName: 'chapter',
      label: 'Chapter',
      wrapText: true
    },
    {
      type: 'text',
      fieldName: 'parentAccount',
      label: 'Parent account',
      wrapText: true
    },
    {
      type: 'text',
      fieldName: 'location',
      label: 'Location',
      wrapText: true
    },
    {
      type: 'text',
      fieldName: 'numberOfSubmissions',
      label: 'No of submissions',
      wrapText: true
    }
  ]
  searchTerms = {
    catalogName : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Publication__r.Name'
    },
    productName : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Product2.Name'
    },
    quantity : {
      value: null,
      dataType: 'number',
      filterType: 'equal',
      fieldName: 'Quantity'
    },
    totalPrice : {
      value: null,
      dataType: 'number',
      filterType: 'equal',
      fieldName: 'TotalPrice'
    },
    signer : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Opportunity.Signer_text__c'
    },
    closeDate : {
      value: null,
      dataType: 'date',
      filterType: 'equal',
      fieldName: 'Opportunity.CloseDate'
    },
    salesPerson : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Opportunity.Owner.Name'
    },
    opportunityId : {
      value: null,
      dataType: 'string',
      filterType: 'equal',
      fieldName: 'OpportunityId'
    },
    relatedOrg : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Related_Organization__r.Name'
    },
    chapter : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Chapter__r.Name'
    },
    parentAccount : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Opportunity.Account.Name'
    },
    location : {
      value: null,
      dataType: 'string',
      filterType: 'like',
      fieldName: 'Location__r.Name'
    },
    numberOfSubmissions : {
      value: null,
      dataType: 'number',
      filterType: 'equal',
      fieldName: 'Submissions__c'
    },
  }
  sortState = {
    direction: null,
    field: null
  }
  isShowModal = false
  @track toast = {
    isShow: false,
    type: '',
    message: ''
  }
  publicationId
  oppProductsToClone

  // Methods
  connectedCallback() {
    this.getOpportunityProducts(null);
  }

  renderedCallback() {
    if (this.hasRendered) return;
    this.hasRendered = true;

    const style = document.createElement('style');
    style.innerText = `
      th.slds-tree__item.table-th {
        display: table-cell;
      }
      svg.slds-button__icon.slds-button__icon_small {
        width: 1.2rem;
        height: 1.2rem;
      }
    `;
    this.template.querySelector('.componentCard').appendChild(style);
  }

  getOpportunityProducts(searchTerms){
    this.isReady = false
    getData({
      oppId: this.oppId, 
      isCurrentYear: this.isCurrentYear,
      terms: searchTerms
    }).then(data => {
      this.gridData = JSON.parse(
        JSON.stringify(data).replace(
          new RegExp('children_xxx', 'g'), '_children'
        )
      )
      this.isReady = true
    }).catch(error => {
      this.isReady = true
      let errorMsg = 'Unknown error';
      if (Array.isArray(error.body)) {
        errorMsg = error.body.map(e => e.message).join(', ');
      } else if (typeof error.body.message === 'string') {
        errorMsg = error.body.message;
      }
      this.showToast(errorMsg, 'error')
    })
  }

  handleSearchTermsChange(event) {
    let value = event.target.value
    let field = event.target.name
    this.searchTerms[field].value = value
    let searchTerms = [];
    for(let key in this.searchTerms) {
      if(this.searchTerms[key].value) searchTerms.push(this.searchTerms[key])
    }

    if (this.timeOut) clearTimeout(this.timeOut)
    this.timeOut = setTimeout(() => {
      this.isReady = false
      this.getOpportunityProducts(searchTerms)
    },500)
  }

  sortHandler(event){
    this.template.querySelectorAll('.input-link').forEach(item => {
      item.classList.remove('arrow-up');
      item.classList.remove('arrow-down');
    })

    let link = event.target
    let sortField = link.getAttribute('data-value')
    if (sortField == this.sortState.field && this.sortState.direction == 'ASC') {
      this.sortState.direction = 'DESC'
    } else {
      this.sortState.direction = 'ASC'
    }
    this.sortByField(sortField, this.gridData)
    this.sortState.field = sortField
    link.classList.add(this.sortState.direction == 'ASC' ? 'arrow-up' : 'arrow-down');
  }

  sortByField(fieldName, dataArr) {
    let array = dataArr.slice()
    array.forEach(item => {
      if (item.hasOwnProperty(fieldName)) {
        dataArr.sort((a,b) => {
          if (this.sortState.direction == 'ASC') 
            return a[fieldName] < b[fieldName] ? -1 : 1
          else  
            return a[fieldName] > b[fieldName] ? -1 : 1
        })
        if (item.hasOwnProperty('_children')) {
          this.sortByField(fieldName, item['_children'])
        }
      } else if (item.hasOwnProperty('_children')) {
        this.sortByField(fieldName, item['_children'])
      }
    })        
    this.gridData = dataArr.slice()
  }

  handleRowAction(event){
    console.log('Click')
    let row = event.detail.row
    this.publicationId = row.oppProducts[0].Publication__c
    this.oppProductsToClone = row.oppProducts
    this.toggelModal()
  }

  toggelModal() {
    this.isShowModal = this.isShowModal ? false : true
  }

  handleChangePublication(event){
    let publication = event.target.value
    this.publicationId = publication
  }

  handleAddProduct() {
    createNewOppProduct({
      oppId: this.oppId,
      publicationId: this.publicationId,
      oppProductsList: this.oppProductsToClone
    }).then(() => {
      this.toggelModal()
      this.showToast('Product has been added.', 'success')
      this.getOpportunityProducts(null);
    }).catch(error => {
      this.toggelModal()
      this.isReady = true
      let errorMsg = 'Unknown error';
      if (Array.isArray(error.body)) {
        errorMsg = error.body.map(e => e.message).join(', ');
      } else if (typeof error.body.message === 'string') {
        errorMsg = error.body.message;
      }
      this.showToast(errorMsg, 'error')
    })
  }

  showToast(Message, Variant) {
    this.toast.message = Message
    this.toast.type = Variant == 'success' ? 'slds-notify_toast slds-theme_success' : 'slds-notify_toast slds-theme_error'
    this.toast.isShow = true
    setTimeout(() => {
      this.toast.isShow = false
      this.toast.message = ''
      this.toast.type = ''
    }, 5000)
  }

  handleCloseToast() {
    this.toast.isShow = false
    this.toast.message = ''
    this.toast.type = ''
  }

  handleClick111() {
    console.log('I\'m OK')
  }
}