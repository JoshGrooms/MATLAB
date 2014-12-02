/* MEXEMPIRICALCDF - Generates p-values for data using an empirically derived null distribution.
 *
 *	SYNTAX:
 *		p = MexEmpiricalCDF(r, n)
 *
 *	OUTPUT:
 *		p:		[ N x 1 DOUBLES ]
 *				An array of p-values corresponding with the data in r. This will always be a column vector of
 *				double-precision numbers that is the same length as r (length L). Each p-value in this vector is
 *				associated with the corresponding value in r.
 *
 *	INPUTS:
 *		r:		[ N x 1 DOUBLES ] 
 *				The real data distribution. This should be the data that will be tested for statistical significance
 *				after conversion to p-values. This must be a column vector of double-precision numbers of length L.
 *				Additionally, any NaNs or zeros in this vector must be removed prior to invoking this function.
 *
 *		n:		[ M x 1 DOUBLES ]
 *				The null data distribution. This should be an empirically derived null data distribution, which is an
 *				estimate of what the data in r would look like if the null hypothesis that is to be tested is in fact
 *				true. Like r, this must be a column vector of double-precision numbers, but the lengths of r and n do
 *				not necessarily have to agree. Additionally, any NaNs or zeros in this vector must be removed prior to
 *				invoking this function.
 */

/* CHANGELOG
 *	Written by Josh Grooms on 20141121
 */

/// <summary>
///	Serves as the entry point to the MEX function that generates empirical CDFs.
/// </summary>
/// <param name="nargout">The number of arguments that will outputted to MATLAB.</param>
/// <param name="pOut">A pointer to the array of output arguments.</param>
/// <param name="nargin">The number of arguments that are inputted from MATLAB.</param>
/// <param name="pIn">A pointer to the array of input arguments.</param>
void mexFunction(int nargout, mxArray *pOut[], int nargin, const mxArray *pIn[]);
