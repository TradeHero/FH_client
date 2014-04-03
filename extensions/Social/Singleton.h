//
// filename	: Singleton.h
//

#ifndef SINGLETON_H
#define SINGLETON_H

#include <assert.h>
#include <stdlib.h>

template <typename TYPE>
class Singleton
{
public:
	Singleton ()
	{
		assert( msSingleton == NULL );
		int offset = (int)(TYPE*)1 - (int)(Singleton<TYPE>*)(TYPE*)1;
		msSingleton = (TYPE*)((int)this + offset);
	}

	~Singleton ()
	{
	}

	static void Set (TYPE *object)
	{
		msSingleton = object;
	}

	static TYPE &GetSingleton ()
	{
		assert( msSingleton != NULL );
		return (*msSingleton);
	}

	static TYPE *GetSingletonPtr ()
	{
		assert( msSingleton != NULL );
		return msSingleton;
	}

private:
	static TYPE *msSingleton;
};

template <typename TYPE>
TYPE *Singleton<TYPE>::msSingleton = NULL;

#endif