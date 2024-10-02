/*
 * Copyright (c) 2018 Tim van der Molen <tim@kariliq.nl>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef COMPAT_H
#define COMPAT_H

#if !defined(__GNUC__) && !defined(__clang__)
#define __attribute__(a)
#endif

/* macOS defines __dead away */
#ifdef __APPLE__
#undef __dead
#endif

#ifndef __dead
#define __dead		__attribute__((__noreturn__))
#endif

#ifndef __unused
#define __unused	__attribute__((__unused__))
#endif

#include <stdarg.h>
#include <stdio.h>

#ifdef __OpenBSD__
#include <sys/queue.h>
#include <sys/tree.h>
#else
#include "compat/queue.h"
#include "compat/tree.h"
#endif

#ifndef HAVE_ASPRINTF
int	 asprintf(char **, const char *, ...);
int	 vasprintf(char **, const char *, va_list);
#endif

#ifdef HAVE_BE32TOH
#  ifdef HAVE_ENDIAN_H
#    include <endian.h>
#  elif defined(HAVE_SYS_ENDIAN_H)
#    include <sys/endian.h>
#  endif
#else
#  ifdef __APPLE__
#    include <libkern/OSByteOrder.h>
#    define be32toh(x) OSSwapBigToHostInt32(x)
#  elif defined(__sun)
#    include <sys/byteorder.h>
#    define be32toh(x) BE_32(x)
#  else
#    error "be32toh() not available"
#  endif
#endif

#ifdef HAVE_ERR
#include <err.h>
#else
void	 err(int, const char *, ...) __dead;
void	 errc(int, int, const char *, ...) __dead;
void	 errx(int, const char *, ...) __dead;
void	 verr(int, const char *, va_list) __dead;
void	 verrc(int, int, const char *, va_list) __dead;
void	 verrx(int, const char *, va_list) __dead;
void	 warn(const char *, ...);
void	 warnc(int, const char *, ...);
void	 warnx(const char *, ...);
void	 vwarn(const char *, va_list);
void	 vwarnc(int, const char *, va_list);
void	 vwarnx(const char *, va_list);
#endif

#ifndef HAVE_EVP_MD_CTX_NEW
#define EVP_MD_CTX_new	EVP_MD_CTX_create
#define EVP_MD_CTX_free	EVP_MD_CTX_destroy
#endif

#ifdef HAVE_EXPLICIT_BZERO
#include <strings.h> /* For FreeBSD */
#else
void	 explicit_bzero(void *, size_t);
#endif

#ifndef HAVE_FOPEN_X_MODE
FILE	*xfopen(const char *, const char *);

#define fopen xfopen
#endif

#ifndef HAVE_GETPROGNAME
const char	*getprogname(void);
void		 setprogname(const char *);
#endif

#ifdef HAVE_HKDF
#include <openssl/hkdf.h>
#else
#include "compat/hkdf.h"
#endif

#ifndef HAVE_HMAC_CTX_NEW
#include <openssl/hmac.h>

HMAC_CTX	*HMAC_CTX_new(void);
void		 HMAC_CTX_free(HMAC_CTX *);
#endif

#ifndef HAVE_PLEDGE
int	 pledge(const char *, const char *);
#endif

#ifdef HAVE_READPASSPHRASE
#include <readpassphrase.h>
#else
#include "compat/readpassphrase.h"
#endif

#ifndef HAVE_REALLOCARRAY
void	*reallocarray(void *, size_t, size_t);
#endif

#ifndef HAVE_UNVEIL
int	 unveil(const char *, const char *);
#endif

/* ensure mkdir(pathname, mode) exists */
#ifdef HAVE_MKDIR
# ifdef MKDIR_TAKES_ONE_ARG
#  define mkdir(a, b) _mkdir(a)
# endif
#endif

#endif
