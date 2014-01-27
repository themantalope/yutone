#include "ind2sub.h"
#include <math.h>

void ind2sub(int *siz, int N, int idx, int *sub)
{
	if (0)
	{
		int prod[4];
		prod[0] = siz[3]*siz[2]*siz[1];
		prod[1] = siz[3]*siz[2];
		prod[2] = siz[3];
		prod[3] = 1;
		sub[0] = (int)floor(	(float)idx / prod[0]							);
		sub[1] = (int)floor(	(float)(	idx % prod[0]	)/prod[1]				);
		sub[2] = (int)floor( (float)( (	idx % prod[0]	)%prod[1]	)  / prod[2]);
		sub[3] = 		( (	idx % prod[0]	)%prod[1]	)  % prod[2] ;
	}
	else
	{
		int *prod = new int [N];
		for (int i = 0; i < N; i++)
		{
			prod[i] = 1;
			for (int j = N-1; j > i; j--)
				prod[i] *= siz[j];
		}
		//sub[0] = (int)floor( (float)idx / prod[0] );
		
		for (int i = 0; i < N; i++)
		{
			sub[i] = idx ;
			for (int j = 0; j < i ; j++)
				sub[i] = sub[i] % prod[j];
			sub[i] = (int)floor( (float)sub[i] / prod[i] );
		}
		//sub[N-1] = idx ;
		//for (int j = 0; j < N -1; j++)
		//	sub[N-1] = sub[N-1] % prod[j];

		delete [] prod;
	}
}

int sub2ind(int *siz, int N, int *sub)
{
	int idx =	0;
	if (0)
		idx =		sub[0]*siz[3]*siz[2]*siz[1]
				+	sub[1]*siz[3]*siz[2]
				+	sub[2]*siz[3]
				+	sub[3];
	else
	{
		for (int i = 0; i < N; i++)
		{
			int prod = 1;
			for (int j = N-1; j > i; j--)
				prod *= siz[j];
			idx += sub[i] * prod;
		}
	}
	return idx;
}

