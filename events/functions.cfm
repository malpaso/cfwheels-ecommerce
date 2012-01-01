<!--- Place functions here that should be globally available in your application. --->

<cfscript>
	// CUSTOM VALIDATORS
	
	// Emails
	public function cvEmailValidator(){
		return "/^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/";
	}
	// Numbers
	public function cvPhoneNumberValidator(){
		return "/^\d?(?:(?:[\+]?(?:[\d]{1,3}(?:[ ]+|[\-.])))?[(]?(?:[\d]{3})[\-)]?(?:[ ]+)?)?(?:[a-zA-Z2-9][a-zA-Z0-9 \-.]{6,})(?:(?:[ ]+|[xX]|(i:ext[\.]?)){1,2}(?:[\d]{1,5}))?$/";	
	}
	
	public function cvUsAndCanadaZipCodeValidator(){
		return "/(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXYabceghjklmnprstvxy]{1}\d{1}[A-Za-z]{1} *\d{1}[A-Za-z]{1}\d{1}$)/";	
	}
	
	public function cvUspsTrackingNumberValidator(){
		return "/\b(91\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d|91\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d)\b/i";	
	}
	
	public function cvFedexTrackingNumberValidator(){
		return "/^([0-9]{15}|4[0-9]{11})$/";	
	}
	
	public function cvUpsTrackingNumberValidator(){
		return "/^(1Z\s*\d{3}\s*\d{3}\s*\d{2}\s*\d{4}\s*\d{3}\s*\d|[0-35-9]\d{3}\s*\d{4}\s*\d{4}|T\d{3}\s*\d{4}\s*\d{3})$/";	
	}

	// Names
	public function cvNameValidator(){
		return "/^([a-z]|[\\']|[']|[\.]|[\s]|[-]|)+([a-z]|[\.])+$/i";
	}
	
	// Credit Cards
	public function cvCreditCardNumberValidator(type){
		var regex = "";
		switch (arguments.type){
			case "AMEX,AmericanExpress": regex = "/^3[47][0-9]{13}$/"; break;
			case "DINERS,DinersClub": regex = "/^3(?:0[0-5]|[68][0-9])[0-9]{11}$/"; break;
			case "Discover,DiscoverCard": regex = "/^6(?:011|5[0-9]{2})[0-9]{12}$/"; break;
			case "JCB": regex = "/^(?:2131|1800|35\d{3})\d{11}$/"; break;
			case "MC,MasterCard": regex = "/^5[1-5][0-9]{14}$/"; break;
			case "VISA,Visa": regex = "/^4[0-9]{12}(?:[0-9]{3})?$/"; break;
			default:break;
		}
		return regex;
	}
</cfscript>