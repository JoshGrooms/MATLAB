/* MEXWINDOWCORRELATE - Computes the sliding window correlation between an array of signals and one or more other signals.
 * 
 *	MEXWINDOWCORRELATE computes the sliding window correlation between two sets of signals over time. This creates a set of 
 *	time series showing how correlation between two data sets changes as a function of time. It is particularly useful in  
 *	analysing relationships between data that have non-stationary or time-varying statistical properties (such as my fMRI and 
 *	EEG data).
 *
 *	SYNTAX:
 *		swc = MexWindowCorrelate(x, y, window, noverlap)
 *
 *	OUTPUT:
 *		swc:			[ MC x NC DOUBLES ]
 *						An array of sliding window correlation values calculated between the data in X and Y. Each row of 
 *						this array contains Pearson correlation coefficients (i.e. r values) between a specific segment of 
 *						the signals in X and Y. The number of correlation time points MC will always follow this formula:
 *
 *							MC = floor( (M - WINDOW) / (WINDOW - NOVERLAP) )
 *						
 *						The number of correlation signals NC in this array will always follow NC = NX * NY in order to hold 
 *						all possible pairings of signals. Each successive column in SWC then represents the correlation over 
 *						time between one signal in Y and a successive signal in X. Each grouping of NX columns in this array 
 *						therefore corresponds with the correlation between one signal in Y and all signals in X. Successive 
 *						groupings correspond with successive signals in Y.
 *
 *	INPUTS:
 *		x:				[ M x NX DOUBLES ]
 *						An array of doubles containing the signal(s) to be correlated with each signal in Y. Each column of 
 *						this array represents a single signal with M time points. The number of signals NX is free to vary 
 *						but must be a positive integer. The number of time points M must always equal M from Y.
 *
 *		y:				[ M x NY DOUBLES ]
 *						An array of doubles containing the signal(s) to be correlated with each signal in X. Each column of 
 *						this array represents a single signal with M time points. The number of signals NY is free to vary 
 *						but must be a positive integer. The number of time points M must always equal M from X.
 *
 *		window:			INT
 *						The number of samples that constitute a single window. More specifically, this argument is the length 
 *						of the window in signal samples. 
 *
 *		noverlap:		INT
 *						The number of samples to be reused in successive correlation estimates. This is how many sample 
 *						points are "overlapped" from previous estimates as the window slides along a signal. This argument 
 *						must be an integer between 0 and WINDOW - 1.
 *
 *	See also: CCORR, SWCORR
 */

/* CHANGELOG
 * Written by Josh Grooms on 20150203
 */

#include <cilk\cilk.h>
#include <mathimf.h>
#include <mex.h>



/* PROTOTYPES */
double corr(double x[], double y[], int nsamples);



/* MEX FUNCTION */
void mexFunction(int nargout, mxArray* argout[], int nargin, const mxArray* argin[])
{
	if (nargin != 4)
		mexErrMsgTxt("Four input arguments must be provided to this function. See documentation for syntax details.");

	double* x = mxGetPr(argin[0]);
	double* y = mxGetPr(argin[1]);

	int window = (int)mxGetScalar(argin[2]);
	int noverlap = (int)mxGetScalar(argin[3]);
	int increment = window - noverlap;

	int ncx, ncy, nrx, nry;
	nrx = mxGetM(argin[0]);
	ncx = mxGetN(argin[0]);
	nry = mxGetM(argin[1]);
	ncy = mxGetN(argin[1]);

	if (nrx == 0 || nry == 0) { mexErrMsgTxt("Inputs cannot be empty arrays."); }
	if (nrx != nry) { mexErrMsgTxt("X and Y must contain equivalent length signals."); }

	// We need a higher precision calculation for the number of SWC points per signal. Otherwise, if this ends up being fractional, 
	// it could get rounded up and result in out-of-bounds indexing later on. We need to always force it downward.
	float temp = (float)(nrx - window) / (float)increment;
	int nswc = (int)floor(temp);

	argout[0] = mxCreateDoubleMatrix(nswc, ncx * ncy, mxREAL);
	double* swc = mxGetPr(argout[0]);

	int nrxToUse = nswc * increment;
	if (ncy == 1)
	{
		cilk_for (int a = 0; a < ncx; a++)
		{
			int idxSWC = a * nswc;
			int idxColX = a * nrx;
			for (int b = 0; b < nrxToUse; b += increment)
				swc[idxSWC++] = corr(x + idxColX + b, y + b, window);
		}

	}
	else
	{
		cilk_for (int a = 0; a < ncy; a++)
		{
			int idxColY = a * nry;
			for (int b = 0; b < ncx; b++)
			{
				int idxSWC = nswc * (a * ncx + b);
				int idxColX = b * nrx;
				for (int c = 0; c < nrxToUse; c += increment)
					swc[idxSWC++] = corr(x + idxColX + c, y + idxColY + c, window);
			}
		}
	}
}



/* SUBROUTINES */
/// <summary>
/// Computes the Pearson product-moment correlation coefficient between two signals.
/// </summary>
/// <param name="x">A signal vector.</param>
/// <param name="y">A second signal vector of the same length as x.</param>
/// <param name="nsamples">The number of sample points in x and y.</param>
/// <returns>The correlation coefficient (r) between x and y.</returns>
double corr(double x[], double y[], int nsamples)
{
	double sx, sy, sxy, ssx, ssy;
	sx = sy = sxy = ssx = ssy = 0;
	for (int a = 0; a < nsamples; a++)
	{
		sx += x[a];
		sy += y[a];
		sxy += x[a] * y[a];
		ssx += x[a] * x[a];
		ssy += y[a] * y[a];
	}

	double cov = (nsamples * sxy) - (sx * sy);
	double scale = sqrt((nsamples * ssx) - (sx * sx)) * sqrt((nsamples * ssy) - (sy * sy));

	return cov / scale;
}
