({
    /**
     * This function will be called on component initialization
     * Attaching a document listner to detect clicks on the page
     * 1. Handle logic when click on dropdown/picklist button itself
     * 2. Handle logic when picklist option is clicked
     * 3. Handle logic when anywhere within picklist is clicked
     * 4. Handle logic if clicked anywhere else
     * @author - Manish Choudhari
     * */
    onRender : function(component, event, helper) {
        if(!component.get("v.initializationCompleted")){
            //Attaching document listener to detect clicks
            component.getElement().addEventListener("click", function(event){
                //handle click component
                helper.handleClick(component, event, 'component');
            });
            //Document listner to detect click outside multi select component
            document.addEventListener("click", function(event){
                helper.handleClick(component, event, 'document');
            });
            //Marking initializationCompleted property true
            component.set("v.initializationCompleted", true);
            //Set picklist name
            helper.setPickListName(component, component.get("v.selectedOptions"));
        }

    },

})