/*******************************************************************************

    Simple fiber token hash generator, uses the C stdlib rand() random number
    generator.

    Copyright: Copyright (c) 2016-2017 sociomantic labs GmbH. All rights reserved

    License:
        Boost Software License Version 1.0. See LICENSE_BOOST.txt for details.

*******************************************************************************/

module swarm.neo.util.FiberTokenHashGenerator;

struct FiberTokenHashGenerator
{
    import swarm.neo.util.MessageFiber;
    import core.stdc.stdlib: rand;

// static assert(RAND_MAX == int.max);

    /***************************************************************************

        The random hash value generated by create() and obtained by get().
        This value is negative iff `receive = true` was passed to `create()`.

    ***************************************************************************/

    private int hash;

    /***************************************************************************

        Generates a new hash, stores it in this instance and creates a fiber
        token containing that hash.

        Params:
            receive = set to true to make the hash negative (intended to
                      distinguish whether a fiber is waiting for input rather
                      than output)

        Returns:
            the fiber token.

        Out:
            `receive` is consistent with what `this.receiving()` returns.

    ***************************************************************************/

    MessageFiber.Token create ( bool receive = false )
    out
    {
        if (receive)
        {
            assert(this.receiving);
        }
        else
        {
            assert(!this.receiving);
        }
    }
    body
    {
        this.hash = rand();

        if (receive)
            this.hash = ~this.hash;

        return this.get();
    }

    /***************************************************************************

        Returns:
            a fiber token containing the hash generated most recently with
            `create()`.

    ***************************************************************************/

    MessageFiber.Token get ( )
    {
        return MessageFiber.Token(this.hash);
    }

    /***************************************************************************

        Returns:
            the `receive` value passed to the most recent call of `create()`.

    ***************************************************************************/

    bool receiving ( )
    {
        return this.hash < 0;
    }
}
