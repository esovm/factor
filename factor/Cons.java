/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2003, 2005 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor;

/**
 * Used to build up linked lists in Factor style.
 */
public class Cons implements FactorExternalizable
{
	public Object car;
	public Object cdr;

	//{{{ Cons constructor
	public Cons(Object car, Object cdr)
	{
		this.car = car;
		this.cdr = cdr;
	} //}}}

	//{{{ next() method
	public Cons next()
	{
		return (Cons)cdr;
	} //}}}

	//{{{ isList() method
	public static boolean isList(Object list)
	{
		if(list == null)
			return true;
		else if(list instanceof Cons)
			return isList(((Cons)list).cdr);
		else
			return false;
	} //}}}

	//{{{ contains() method
	public static boolean contains(Cons list, Object obj)
	{
		while(list != null)
		{
			if(FactorLib.objectsEqual(obj,list.car))
				return true;
			list = list.next();
		}
		return false;
	} //}}}

	//{{{ length() method
	public static int length(Cons list)
	{
		int size = 0;
		while(list != null)
		{
			size++;
			list = list.next();
		}
		return size;
	} //}}}

	//{{{ reverse() method
	public static Cons reverse(Cons list)
	{
		Cons reversed = null;
		while(list != null)
		{
			reversed = new Cons(list.car,reversed);
			list = list.next();
		}
		return reversed;
	} //}}}

	//{{{ elementsToString() method
	/**
	 * Returns a whitespace separated string of the unparseObject() of each
	 * item.
	 */
	public String elementsToString()
	{
		StringBuffer buf = new StringBuffer();
		Cons iter = this;
		while(iter != null)
		{
			buf.append(FactorReader.unparseObject(iter.car));
			buf.append(' ');
			iter = iter.next();
		}

		return buf.toString();
	} //}}}

	//{{{ toString() method
	/**
	 * Returns elementsToString() enclosed with [ and ].
	 */
	public String toString()
	{
		if(isList(this))
			return "[ " + elementsToString() + " ]";
		else
		{
			return "[[ " + FactorReader.unparseObject(car)
				+ " " + FactorReader.unparseObject(cdr)
				+ " ]]";
		}
	} //}}}

	//{{{ toArray() method
	/**
	 * Note that unlike Java list toArray(), the given array must already
	 * be the right size.
	 */
	public Object[] toArray(Object[] returnValue)
	{
		int i = 0;
		Cons iter = this;
		while(iter != null)
		{
			returnValue[i++] = iter.car;
			iter = iter.next();
		}
		return returnValue;
	} //}}}

	//{{{ fromArray() method
	public static Cons fromArray(Object[] array)
	{
		if(array == null || array.length == 0)
			return null;
		else
		{
			Cons first = new Cons(array[0],null);
			Cons last = first;
			for(int i = 1; i < array.length; i++)
			{
				Cons cons = new Cons(array[i],null);
				last.cdr = cons;
				last = cons;
			}
			return first;
		}
	} //}}}

	//{{{ equals() method
	public boolean equals(Object o)
	{
		if(o instanceof Cons)
		{
			Cons l = (Cons)o;
			return FactorLib.objectsEqual(car,l.car)
				&& FactorLib.objectsEqual(cdr,l.cdr);
		}
		else
			return false;
	} //}}}

	//{{{ hashCode() method
	public int hashCode()
	{
		if(car == null)
			return 0;
		else
			return car.hashCode();
	} //}}}
}
