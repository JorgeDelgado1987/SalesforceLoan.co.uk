public class APR {

	//Method to caclualte APR
	// based on http://stackoverflow.com/questions/3102476/calculating-annual-percentage-rate-need-some-help-with-inherited-code
	// Simon Parker 02/10/2014


public APR() {
	
}

public static decimal calculateAPR(Decimal TotalAmount, Decimal MonthlyPayment, Integer NumPayments){
/*
	Takes TotalAmount as Total borrowed excluding fees ie amount received
	Estimated monthly payment for Total Loan + Fees
	Number of payments (months)
*/
	double numPay = NumPayments;
	double payment = MonthlyPayment;
	double amount = TotalAmount;

	/*for testing
	numPay = 30;
	payment = 7027.77;
	amount = 200000;
	*/

	double error = Math.pow(10,-5);
	double approx = 0.05/12; // let's start with a guess that the APR is 5% 
	double prev_approx;
	double diff;

	for (integer k=0;k<20;++k) {
	       prev_approx = approx;
	       approx = prev_approx - F(prev_approx, amount, numPay, payment)/F_1(prev_approx,  amount, numPay, payment);
	       diff = Math.abs(approx-prev_approx);

	       system.debug('new guess ' + approx + ' diff is ' +  diff);
	       if (diff < error) break;
	}

	decimal apr = (approx * 12 * 10000)/100; // this way we get APRs like 7.5% or 6.55%
	system.debug('APR is ' + apr + ' final approx ' +approx);
	return apr;
}

private static decimal F(double x, double amount, double numPay, double payment) {
	decimal calc = (amount * x * Math.pow(1 + x,numPay)/(Math.pow(1 + x,numPay) - 1) - payment);
	return calc;
}

private static decimal F_1(double x, double amount, double numPay, double payment) {
	decimal calc = (amount * ( Math.pow(1 + x,numPay)/(-1 + Math.pow(1 + x,numPay)) - numPay * x * Math.pow(1 + x,-1 + 2*numPay)/Math.pow(-1 + Math.pow(1 + x,numPay),2) + numPay * x * Math.pow(1 + x,-1 + numPay)/(-1 + Math.pow(1 + x,numPay)))); 
	return calc;
}

}