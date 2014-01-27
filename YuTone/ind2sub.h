/** \file 

	\brief This file contains code for interchanging between 
			linear index and subscript for any N-dimensional array 
			- this code provides CPP implementation of the MATLAB 
			calls ind2sub and sub2ind

*/

//*********************************************
/*!
\fn				void ind2sub(int *siz, int N, int idx, int *sub)
\brief			This function determines the equivalent subscript values corresponding 
				to the absolute index dimension of a multidimensional array.

\author			Kriti Sen Sharma
\date			2011-05-04
\param[in]	siz		size of the N-dimensional matrix
\param[in]	N		the dimensions of the matrix
\param[in]	idx		index in linear format
\param[out]	sub		the output - subscript values written into an N-dimensional integer array 
					(created by the caller)

\details			Example for a 2-D array of size [3, 5] : siz[] = {3, 5}; N = 2
		- if linear index is 0, subscript is (0, 0)
		- if linear index is 1, subscript is (0, 1)
		- if linear index is 5, subscript is (1, 0)
		- if linear index is 14, subscript is (2, 4)

*/
//
//**********************************************
void ind2sub(int *siz, int N, int idx, int *sub);

//*********************************************
/*!
\fn				int sub2ind(int *siz, int N, int *sub)
\brief			This function determines the equivalent index value corresponding 
				to the subscript values of a multidimensional array.

\author			Kriti Sen Sharma
\date			2011-05-04
\param[in]	siz		size of the N-dimensional matrix
\param[in]	N		the dimensions of the matrix
\param[out]	sub		subscripts stored in an N-dimensional array
\return		(integer) the linear index corresponding to the subscript

\details			Example for a 2-D array of size [3, 5] : siz[] = {3, 5}; N = 2
		- if subscript is (0, 0), linear index is 0 
		- if subscript is (0, 1), linear index is 1 
		- if subscript is (1, 0), linear index is 5
		- if subscript is (2, 4), linear index is 14

*/
int sub2ind(int *siz, int N, int *sub);
