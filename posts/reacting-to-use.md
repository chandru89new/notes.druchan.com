---
title: Reacting to React's use()
date: 2026-05-31
slug: reacting-to-use
status: published
---

Years ago, I used to work as a tech blogger covering iOS how-tos for the iPhone 4 series. Apple iOS was a very restrictive system unlike Android, and the only way you could customize your iPhone beyond the limited native options was to "jailbreak" the phone, install something like [Cydia](https://www.cydiafree.com/) (a marketplace for apps that can only be installed on a jailbroken iPhone), and download the apps that made it possible to customize the phone.

You couldn't even customize the notification sheet, or the status bar on a normal iPhone. But once jailbroken, almost everything was possible.

The most weird bit was this: many of the customizations that jailbreaking offered would eventually be supported natively by Apple. It wasn't just the Android folks that would make fun of Apple because it was so late to the party and yet making it sound like it was so innovative. The jailbreaking community too made fun of Apple for the very same reason.

That is precisely how I feel about `use()`.

The idea goes by many names in other ecosystems (and frameworks within the JS ecosystem). You can call it an AsyncWrapper, or a DataWrapper, or LCE (Load/Content/Error), or QueryWrapper or whatever. The basic concept is simple:

A wrapper takes an async function call that could return some data or an error, and then it will show you one of three things:

- A loading state when the async function is being called and awaited
- An error state if the result is an error/exception
- A content state if the result is content

Almost a decade ago, we used to write simple wrapping components that could be used like these:

```jsx
<DataWrapper
    query={asyncFunction}
    loader={<LoadingComponent />}
    error={(e) => <ErrorComponent err={e} />}
>
{(content) => <Render data={content} />}
</Data>
```

Literally. A decade ago. We figured out the syntax of the abstraction a decade ago. The abstraction itself predates most of us.

And now you're telling me this is better?

```jsx
const UserPage = () => {
    const userPromise = fetch(...);
    return (
        <ErrorBoundary fallback={<ErrorMsg />}>
            <Suspense fallback={<LoadingComponent />}>
                <UserProfile userPromise={userPromise} />
            </Suspense>
        </ErrorBoundary>
    )
}

const UserProfile = ({ userPromise }) => {
    const data = use(userPromise);
    return <UserCard data={data} />
}
```

How is it better?

- I have to ensure and repeat the Suspense and ErrorBoundary components are present, otherwise the app will crash
- I have to create a "called" promise function (it's not even a thunk) and then pass _that_ to the child. I've heard of passing data and then I've heard of passing functions. What nonsense is this passing of a called promise?
- There are restrictions anyway on `use` where it can't be called inside a function that's not a component or a hook — and not in `try / catch` blocks either
- Error-boundaries in React are weirdly shaped and you'd better rely on another package for easy error boundaries (which still has its own complications).

Am I getting older or are React folks really complicating things? The `use` is a good example of, "look, we know our earlier hooks had various conditions, so here's a new one that removes those conditions but brings a new set of its own."

React has made building web apps insanely simple with a lot of bells and whistles for sure, but just like the parent (Facebook) where it was incubated, _at what cost_?
